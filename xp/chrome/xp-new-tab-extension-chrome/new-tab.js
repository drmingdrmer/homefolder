// Global bookmarks store
let allBookmarks = {};
let config = {
    maxEntriesPerColumn: 10
};
let bookmarkToDelete = null;

function createBookmarkElement(bookmark) {
    // Create container for the bookmark item and delete button
    const container = document.createElement('div');
    container.className = 'bookmark-item';

    // Create the bookmark link
    const link = document.createElement('a');
    link.href = bookmark.url;
    link.textContent = bookmark.title || bookmark.url;
    link.className = 'bookmark-link';
    container.appendChild(link);

    // Create delete button
    const deleteBtn = document.createElement('button');
    deleteBtn.className = 'delete-button';
    deleteBtn.textContent = '×';
    deleteBtn.setAttribute('aria-label', 'Delete bookmark');
    deleteBtn.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        showDeleteConfirmation(bookmark);
    });
    container.appendChild(deleteBtn);

    return container;
}

function createSubfolderHeader(title) {
    const header = document.createElement('div');
    header.className = 'subfolder';
    header.textContent = title;
    return header;
}

function collectAllBookmarks(nodes, parentFolder = null) {
    nodes.forEach(node => {
        if (node.children) {
            // This is a folder
            allBookmarks[node.id] = {
                id: node.id,
                title: node.title,
                parentId: node.parentId,
                isFolder: true,
                children: node.children.map(child => child.id)
            };
            collectAllBookmarks(node.children, node);
        } else if (node.url) {
            // This is a bookmark
            allBookmarks[node.id] = {
                id: node.id,
                title: node.title || node.url,
                url: node.url,
                parentId: node.parentId,
                isFolder: false
            };
        }
    });
}

function renderBookmarks() {
    const container = document.getElementById('bookmarks-container');
    container.innerHTML = '';

    // Get top-level folders
    const topLevelFolders = Object.values(allBookmarks).filter(item =>
        item.isFolder && (item.parentId === '0' || item.parentId === '1')
    );

    // Sort folders alphabetically
    topLevelFolders.sort((a, b) => a.title.localeCompare(b.title));

    // Process each top-level folder
    topLevelFolders.forEach(folder => {
        if (!folder.children || folder.children.length === 0) return;

        // Count total items in folder (recursive)
        const itemCount = countItemsInFolder(folder);

        if (itemCount <= config.maxEntriesPerColumn) {
            // Create a single column for this folder
            const folderColumn = createFolderColumn(folder.title);

            // Add all items to the column
            processBookmarksInFolder(folder.children, folderColumn.content);

            // Add the column to the container
            container.appendChild(folderColumn.column);
        } else {
            // We need to split this folder into multiple columns
            splitFolderIntoColumns(folder, container);
        }
    });
}

function countItemsInFolder(folder) {
    if (!folder.children) return 0;

    let count = 0;
    folder.children.forEach(childId => {
        const item = allBookmarks[childId];
        if (!item) return;

        if (item.isFolder) {
            // Add the subfolder count
            count += countItemsInFolder(item);
        } else {
            // Add this bookmark
            count++;
        }
    });

    return count;
}

function createFolderColumn(title, subtitle = null) {
    const folderColumn = document.createElement('div');
    folderColumn.className = 'folder-column';

    const folderHeader = document.createElement('div');
    folderHeader.className = 'folder-header';
    folderHeader.textContent = title;

    if (subtitle) {
        const subheader = document.createElement('span');
        subheader.className = 'folder-subheader';
        subheader.textContent = subtitle;
        folderHeader.appendChild(subheader);
    }

    folderColumn.appendChild(folderHeader);

    const folderContent = document.createElement('div');
    folderContent.className = 'folder-content';
    folderColumn.appendChild(folderContent);

    return { column: folderColumn, content: folderContent };
}

function splitFolderIntoColumns(folder, container) {
    if (!folder.children || folder.children.length === 0) return;

    // First, separate direct bookmarks from subfolders
    const directBookmarks = [];
    const subfolders = [];

    folder.children.forEach(childId => {
        const item = allBookmarks[childId];
        if (!item) return;

        if (item.isFolder) {
            subfolders.push(item);
        } else {
            directBookmarks.push(item);
        }
    });

    // Add direct bookmarks to their own column if there are any
    if (directBookmarks.length > 0) {
        const chunkedBookmarks = chunkArray(directBookmarks, config.maxEntriesPerColumn);

        chunkedBookmarks.forEach((chunk, index) => {
            const subtitle = chunkedBookmarks.length > 1 ? `Direct links (${index + 1}/${chunkedBookmarks.length})` : 'Direct links';
            const { column, content } = createFolderColumn(folder.title, subtitle);

            chunk.forEach(bookmark => {
                content.appendChild(createBookmarkElement(bookmark));
            });

            container.appendChild(column);
        });
    }

    // Process subfolders
    subfolders.forEach(subfolder => {
        const itemCount = countItemsInFolder(subfolder);

        if (itemCount <= config.maxEntriesPerColumn) {
            // This subfolder fits in one column
            const { column, content } = createFolderColumn(folder.title, subfolder.title);
            processBookmarksInFolder(subfolder.children, content);
            container.appendChild(column);
        } else {
            // This subfolder needs to be split
            splitSubfolderIntoColumns(folder.title, subfolder, container);
        }
    });
}

function splitSubfolderIntoColumns(parentTitle, subfolder, container) {
    // Collect all bookmarks in this subfolder (flattened)
    const allSubfolderBookmarks = [];

    function collectBookmarks(childIds) {
        childIds.forEach(childId => {
            const item = allBookmarks[childId];
            if (!item) return;

            if (item.isFolder) {
                if (item.children) {
                    collectBookmarks(item.children);
                }
            } else {
                allSubfolderBookmarks.push(item);
            }
        });
    }

    collectBookmarks(subfolder.children);

    // Split into chunks
    const chunks = chunkArray(allSubfolderBookmarks, config.maxEntriesPerColumn);

    // Create a column for each chunk
    chunks.forEach((chunk, index) => {
        const subtitle = `${subfolder.title} (${index + 1}/${chunks.length})`;
        const { column, content } = createFolderColumn(parentTitle, subtitle);

        chunk.forEach(bookmark => {
            content.appendChild(createBookmarkElement(bookmark));
        });

        container.appendChild(column);
    });
}

function chunkArray(array, chunkSize) {
    const chunks = [];
    for (let i = 0; i < array.length; i += chunkSize) {
        chunks.push(array.slice(i, i + chunkSize));
    }
    return chunks;
}

function processBookmarksInFolder(childIds, container) {
    let currentSubfolder = null;

    // Process items in order
    childIds.forEach(childId => {
        const item = allBookmarks[childId];
        if (!item) return;

        if (item.isFolder) {
            // This is a subfolder, add a header
            const subfolderHeader = createSubfolderHeader(item.title);
            container.appendChild(subfolderHeader);
            currentSubfolder = item;

            // Process bookmarks in this subfolder
            if (item.children && item.children.length > 0) {
                processBookmarksInFolder(item.children, container);
            }
        } else {
            // This is a bookmark, add it to the container
            container.appendChild(createBookmarkElement(item));
        }
    });
}

function filterBookmarks(searchTerm) {
    const container = document.getElementById('bookmarks-container');

    if (!searchTerm.trim()) {
        // Reset to normal view if search is cleared
        renderBookmarks();
        return;
    }

    container.innerHTML = '';

    const lowercaseSearch = searchTerm.toLowerCase();

    // FIRST SECTION: Find folders that match the search term
    const matchingFolders = Object.values(allBookmarks).filter(item =>
        item.isFolder && item.title.toLowerCase().includes(lowercaseSearch)
    );

    // SECOND SECTION: Find bookmarks that match the search term
    const matchingBookmarks = Object.values(allBookmarks).filter(item =>
        !item.isFolder && item.title.toLowerCase().includes(lowercaseSearch)
    );

    // If no matches at all
    if (matchingFolders.length === 0 && matchingBookmarks.length === 0) {
        const noResults = document.createElement('div');
        noResults.textContent = 'No bookmarks or folders found matching your search.';
        noResults.style.padding = '20px';
        noResults.style.textAlign = 'center';
        container.appendChild(noResults);
        return;
    }

    // Add summary at the top
    const summaryColumn = document.createElement('div');
    summaryColumn.className = 'folder-column';
    summaryColumn.style.gridColumn = '1 / -1';
    summaryColumn.style.marginBottom = '10px';

    const summaryHeader = document.createElement('div');
    summaryHeader.className = 'folder-header';

    let summaryText = 'Search Results:';
    if (matchingFolders.length > 0) {
        summaryText += ` ${matchingFolders.length} folder${matchingFolders.length > 1 ? 's' : ''}`;
    }
    if (matchingFolders.length > 0 && matchingBookmarks.length > 0) {
        summaryText += ' and';
    }
    if (matchingBookmarks.length > 0) {
        summaryText += ` ${matchingBookmarks.length} bookmark${matchingBookmarks.length > 1 ? 's' : ''}`;
    }
    summaryText += ` found matching "${searchTerm}"`;

    summaryHeader.textContent = summaryText;
    summaryColumn.appendChild(summaryHeader);
    container.appendChild(summaryColumn);

    // SECTION 1: Display matching folders with their contents
    if (matchingFolders.length > 0) {
        const folderSectionHeader = document.createElement('div');
        folderSectionHeader.className = 'folder-column';
        folderSectionHeader.style.gridColumn = '1 / -1';
        folderSectionHeader.style.marginBottom = '5px';

        const headerDiv = document.createElement('div');
        headerDiv.className = 'folder-header';
        headerDiv.textContent = 'Matching Folders';
        folderSectionHeader.appendChild(headerDiv);

        container.appendChild(folderSectionHeader);

        // Process each matching folder
        matchingFolders.forEach(folder => {
            // Get folder path
            const folderPath = getFolderPath(folder);
            const pathDisplay = folderPath.map(f => f.title).join(' > ');

            // Create a column for this folder
            const { column, content } = createFolderColumn(pathDisplay);

            // Highlight the folder name in the header
            const folderHeader = column.querySelector('.folder-header');
            highlightText(folderHeader, searchTerm);

            // Show contents of the folder (limited to avoid overwhelming)
            const MAX_ITEMS_TO_SHOW = 10;
            let itemCount = 0;

            if (folder.children && folder.children.length > 0) {
                folder.children.forEach(childId => {
                    if (itemCount >= MAX_ITEMS_TO_SHOW) return;

                    const item = allBookmarks[childId];
                    if (!item) return;

                    if (!item.isFolder) {
                        // Add bookmark
                        content.appendChild(createBookmarkElement(item));
                        itemCount++;
                    }
                });

                // Add "see more" link if needed
                if (folder.children.length > MAX_ITEMS_TO_SHOW) {
                    const moreLink = document.createElement('a');
                    moreLink.href = "#";
                    moreLink.className = 'bookmark-link';
                    moreLink.textContent = `... and ${folder.children.length - MAX_ITEMS_TO_SHOW} more items`;
                    moreLink.style.fontStyle = 'italic';
                    moreLink.style.textAlign = 'center';
                    moreLink.addEventListener('click', (e) => {
                        e.preventDefault();
                        // Clear search and show this folder's contents
                        document.getElementById('searchBox').value = '';
                        showFolderContents(folder.id);
                    });
                    content.appendChild(moreLink);
                }
            } else {
                const emptyNote = document.createElement('div');
                emptyNote.textContent = 'This folder is empty';
                emptyNote.style.fontStyle = 'italic';
                emptyNote.style.padding = '5px';
                emptyNote.style.opacity = '0.7';
                content.appendChild(emptyNote);
            }

            container.appendChild(column);
        });
    }

    // SECTION 2: Display bookmarks that match the search term
    if (matchingBookmarks.length > 0) {
        const bookmarkSectionHeader = document.createElement('div');
        bookmarkSectionHeader.className = 'folder-column';
        bookmarkSectionHeader.style.gridColumn = '1 / -1';
        bookmarkSectionHeader.style.marginBottom = '5px';
        bookmarkSectionHeader.style.marginTop = '20px';

        const headerDiv = document.createElement('div');
        headerDiv.className = 'folder-header';
        headerDiv.textContent = 'Matching Bookmarks';
        bookmarkSectionHeader.appendChild(headerDiv);

        container.appendChild(bookmarkSectionHeader);

        // Group matches by parent folder
        const folderMatches = {};

        matchingBookmarks.forEach(bookmark => {
            // Find the folder path for this bookmark
            const folderPath = getBookmarkFolderPath(bookmark);
            const folderKey = folderPath.map(f => f.id).join('-');

            if (!folderMatches[folderKey]) {
                folderMatches[folderKey] = {
                    path: folderPath,
                    bookmarks: []
                };
            }
            folderMatches[folderKey].bookmarks.push(bookmark);
        });

        // Create result columns grouped by folder
        Object.values(folderMatches).forEach(group => {
            const { path, bookmarks } = group;

            // Create folder column
            const folderColumn = document.createElement('div');
            folderColumn.className = 'folder-column';

            // Create header with full path
            const folderHeader = document.createElement('div');
            folderHeader.className = 'folder-header';

            // Format the path for display
            const pathDisplay = path.map(f => f.title).join(' > ');
            folderHeader.textContent = pathDisplay;

            // Add match count as subheader
            const matchCount = document.createElement('span');
            matchCount.className = 'folder-subheader';
            matchCount.textContent = `${bookmarks.length} match${bookmarks.length > 1 ? 'es' : ''}`;
            folderHeader.appendChild(matchCount);

            folderColumn.appendChild(folderHeader);

            // Add bookmarks
            const folderContent = document.createElement('div');
            folderContent.className = 'folder-content';

            bookmarks.forEach(bookmark => {
                const link = createBookmarkElement(bookmark);

                // Highlight the matched text
                highlightText(link, searchTerm);

                folderContent.appendChild(link);
            });

            folderColumn.appendChild(folderContent);
            container.appendChild(folderColumn);
        });
    }
}

// Helper function to get the path of a folder (similar to getBookmarkFolderPath)
function getFolderPath(folder) {
    const path = [folder]; // Include the folder itself
    let currentId = folder.parentId;

    // Traverse up the folder hierarchy
    while (currentId) {
        const parentFolder = allBookmarks[currentId];
        if (!parentFolder) break;

        path.unshift(parentFolder); // Add to beginning of array
        currentId = parentFolder.parentId;
    }

    return path;
}

// Helper function to highlight search term in text
function highlightText(element, searchTerm) {
    if (!searchTerm.trim() || !element.textContent) return;

    const text = element.textContent;
    const lcText = text.toLowerCase();
    const lcSearch = searchTerm.toLowerCase();

    if (lcText.includes(lcSearch)) {
        // Find all occurrences
        const parts = [];
        let lastIndex = 0;
        let startIndex = lcText.indexOf(lcSearch);

        while (startIndex !== -1) {
            // Add text before match
            if (startIndex > lastIndex) {
                parts.push({
                    text: text.substring(lastIndex, startIndex),
                    isMatch: false
                });
            }

            // Add match
            const endIndex = startIndex + lcSearch.length;
            parts.push({
                text: text.substring(startIndex, endIndex),
                isMatch: true
            });

            lastIndex = endIndex;
            startIndex = lcText.indexOf(lcSearch, lastIndex);
        }

        // Add any remaining text
        if (lastIndex < text.length) {
            parts.push({
                text: text.substring(lastIndex),
                isMatch: false
            });
        }

        // Clear element and add highlighted content
        element.innerHTML = '';
        parts.forEach(part => {
            if (part.isMatch) {
                const highlight = document.createElement('span');
                highlight.style.backgroundColor = 'rgba(255, 255, 100, 0.3)';
                highlight.style.padding = '0 2px';
                highlight.style.borderRadius = '2px';
                highlight.textContent = part.text;
                element.appendChild(highlight);
            } else {
                const textNode = document.createTextNode(part.text);
                element.appendChild(textNode);
            }
        });
    }
}

// Show contents of a specific folder
function showFolderContents(folderId) {
    const folder = allBookmarks[folderId];
    if (!folder || !folder.isFolder) return;

    const container = document.getElementById('bookmarks-container');
    container.innerHTML = '';

    // Create a "back to all bookmarks" link
    const backColumn = document.createElement('div');
    backColumn.className = 'folder-column';
    backColumn.style.gridColumn = '1 / -1';
    backColumn.style.marginBottom = '15px';

    const backHeader = document.createElement('div');
    backHeader.className = 'folder-header';

    const backLink = document.createElement('a');
    backLink.href = "#";
    backLink.textContent = "← Back to all bookmarks";
    backLink.style.color = "white";
    backLink.style.textDecoration = "none";
    backLink.addEventListener('click', (e) => {
        e.preventDefault();
        renderBookmarks();
    });

    backHeader.appendChild(backLink);
    backColumn.appendChild(backHeader);
    container.appendChild(backColumn);

    // Get folder path
    const folderPath = getFolderPath(folder);
    const pathDisplay = folderPath.map(f => f.title).join(' > ');

    // Create folder content
    const { column, content } = createFolderColumn(pathDisplay);

    // Process folder contents
    if (folder.children && folder.children.length > 0) {
        processBookmarksInFolder(folder.children, content);
    } else {
        const emptyNote = document.createElement('div');
        emptyNote.textContent = 'This folder is empty';
        emptyNote.style.fontStyle = 'italic';
        emptyNote.style.padding = '5px';
        emptyNote.style.opacity = '0.7';
        content.appendChild(emptyNote);
    }

    column.style.gridColumn = '1 / -1';
    container.appendChild(column);
}

// Helper function to get the full folder path for a bookmark
function getBookmarkFolderPath(bookmark) {
    const path = [];
    let currentId = bookmark.parentId;

    // Traverse up the folder hierarchy
    while (currentId) {
        const folder = allBookmarks[currentId];
        if (!folder) break;

        path.unshift(folder); // Add to beginning of array
        currentId = folder.parentId;
    }

    return path;
}

// Show confirmation dialog for bookmark deletion
function showDeleteConfirmation(bookmark) {
    // Store the bookmark to delete
    bookmarkToDelete = bookmark;

    // Create overlay
    const overlay = document.createElement('div');
    overlay.className = 'overlay';
    overlay.id = 'delete-overlay';

    // Create confirmation dialog
    const confirmDialog = document.createElement('div');
    confirmDialog.className = 'delete-confirm';
    confirmDialog.id = 'delete-confirm';

    // Dialog content
    const title = document.createElement('h3');
    title.textContent = 'Delete Bookmark';

    const message = document.createElement('p');
    message.textContent = `Are you sure you want to delete "${bookmark.title}"?`;

    const buttonsContainer = document.createElement('div');
    buttonsContainer.className = 'delete-confirm-buttons';

    const cancelBtn = document.createElement('button');
    cancelBtn.className = 'delete-confirm-cancel';
    cancelBtn.textContent = 'Cancel';
    cancelBtn.addEventListener('click', hideDeleteConfirmation);

    // Add keyboard controls for easier navigation
    cancelBtn.addEventListener('keydown', (e) => {
        if (e.key === 'Tab' && e.shiftKey) {
            e.preventDefault();
            deleteBtn.focus();
        }
    });

    const deleteBtn = document.createElement('button');
    deleteBtn.className = 'delete-confirm-delete';
    deleteBtn.textContent = 'Delete';
    deleteBtn.addEventListener('click', () => {
        deleteBookmark(bookmark.id);
        hideDeleteConfirmation();
    });

    // Add keyboard controls for easier navigation
    deleteBtn.addEventListener('keydown', (e) => {
        if (e.key === 'Tab' && !e.shiftKey) {
            e.preventDefault();
            cancelBtn.focus();
        }
    });

    // Assemble the dialog
    buttonsContainer.appendChild(cancelBtn);
    buttonsContainer.appendChild(deleteBtn);

    confirmDialog.appendChild(title);
    confirmDialog.appendChild(message);
    confirmDialog.appendChild(buttonsContainer);

    // Add to document
    document.body.appendChild(overlay);
    document.body.appendChild(confirmDialog);

    // Focus on the Cancel button by default (safer option)
    cancelBtn.focus();

    // Add keyboard event listener for Escape key
    document.addEventListener('keydown', handleEscapeKey);

    // Also add click on overlay to cancel
    overlay.addEventListener('click', hideDeleteConfirmation);
}

function hideDeleteConfirmation() {
    // Remove the dialog and overlay
    const dialog = document.getElementById('delete-confirm');
    const overlay = document.getElementById('delete-overlay');

    if (dialog) document.body.removeChild(dialog);
    if (overlay) document.body.removeChild(overlay);

    // Remove escape key listener
    document.removeEventListener('keydown', handleEscapeKey);

    // Clear bookmarkToDelete
    bookmarkToDelete = null;
}

function handleEscapeKey(e) {
    if (e.key === 'Escape') {
        hideDeleteConfirmation();
    }
}

function deleteBookmark(id) {
    chrome.bookmarks.remove(id, () => {
        // Check for error
        if (chrome.runtime.lastError) {
            console.error(chrome.runtime.lastError.message);
            return;
        }

        // Update our local store
        const bookmark = allBookmarks[id];
        if (bookmark && bookmark.parentId) {
            const parent = allBookmarks[bookmark.parentId];
            if (parent && parent.children) {
                // Remove from parent's children array
                parent.children = parent.children.filter(childId => childId !== id);
            }
        }

        // Remove from our local store
        delete allBookmarks[id];

        // Refresh the view
        const searchBox = document.getElementById('searchBox');
        if (searchBox.value.trim()) {
            // If search is active, re-filter
            filterBookmarks(searchBox.value);
        } else {
            // Otherwise just render normally
            renderBookmarks();
        }
    });
}

// Settings functions
function toggleSettings() {
    const settingsPanel = document.getElementById('settings-panel');
    settingsPanel.classList.toggle('visible');
}

function saveSettings() {
    const maxEntriesInput = document.getElementById('max-entries');
    config.maxEntriesPerColumn = parseInt(maxEntriesInput.value) || 20;

    // Save to storage
    chrome.storage.sync.set({ config: config }, function () {
        renderBookmarks(); // Re-render with new settings
    });
}

function loadSettings() {
    chrome.storage.sync.get('config', function (result) {
        if (result.config) {
            config = result.config;
            // Update input values
            document.getElementById('max-entries').value = config.maxEntriesPerColumn;
        }
    });
}

document.addEventListener('DOMContentLoaded', () => {
    const searchBox = document.getElementById('searchBox');
    const settingsToggle = document.getElementById('settings-toggle');
    const maxEntriesInput = document.getElementById('max-entries');

    // Load settings
    loadSettings();

    // Event listeners
    settingsToggle.addEventListener('click', toggleSettings);
    maxEntriesInput.addEventListener('change', saveSettings);

    // Click outside to close settings
    document.addEventListener('click', (e) => {
        const settingsPanel = document.getElementById('settings-panel');
        if (e.target !== settingsToggle && !settingsPanel.contains(e.target) && settingsPanel.classList.contains('visible')) {
            settingsPanel.classList.remove('visible');
        }
    });

    chrome.bookmarks.getTree((bookmarkTreeNodes) => {
        collectAllBookmarks(bookmarkTreeNodes);
        renderBookmarks();
    });

    searchBox.addEventListener('input', (e) => {
        filterBookmarks(e.target.value);
    });
}); 
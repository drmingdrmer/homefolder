// Global bookmarks store
let allBookmarks = {};
let config = {
    maxEntriesPerColumn: 10
};
let bookmarkToDelete = null;
// Map to store folder colors
let folderColors = {};
// Seed colors for directories (stronger pastel colors with better contrast on dark backgrounds)
const colorPalette = [
    'rgba(255, 179, 186, 0.15)', // Pink
    'rgba(255, 223, 186, 0.15)', // Peach
    'rgba(255, 255, 186, 0.15)', // Light Yellow
    'rgba(186, 255, 201, 0.15)', // Light Green
    'rgba(186, 225, 255, 0.15)', // Light Blue
    'rgba(186, 200, 255, 0.15)', // Lavender
    'rgba(228, 186, 255, 0.15)', // Light Purple
    'rgba(255, 186, 255, 0.15)', // Light Magenta
    'rgba(200, 255, 248, 0.15)', // Mint
    'rgba(255, 213, 145, 0.15)', // Light Orange
    'rgba(173, 216, 230, 0.15)', // Light Sky Blue
    'rgba(144, 238, 144, 0.15)'  // Light Green
];

// Function to get a unique key for folder coloring
function getFolderColorKey(folder) {
    // For root-level folders, use the folder title to ensure consistent coloring
    if (folder.parentId === '0' || folder.parentId === '1') {
        return folder.title;
    }

    // For direct children of the root folders (like direct links, util, etc.)
    // use the folder's title to ensure they get unique colors
    const parentFolder = allBookmarks[folder.parentId];
    if (parentFolder && (parentFolder.parentId === '0' || parentFolder.parentId === '1')) {
        return folder.title; // Use the actual folder title for direct bookmarks bar children
    }

    // For deeper nested folders, use a combination
    return folder.title;
}

// Function to get color for a folder
function getFolderColor(folderId) {
    const folder = allBookmarks[folderId];
    if (!folder) return colorPalette[0];

    // For the splitFolderIntoColumns case, we need to consider both the parent folder 
    // and the specific subfolder to distinguish "Direct links" from "util"
    let colorKey;

    // If this is a direct child of the root folders, use its title
    const parentFolder = folder.parentId ? allBookmarks[folder.parentId] : null;
    if (parentFolder && (parentFolder.parentId === '0' || parentFolder.parentId === '1')) {
        // For direct children of Bookmarks Bar, we want to use the complete title
        colorKey = folder.title;
    } else {
        // For other cases, use the folder's own title for consistency
        colorKey = getFolderColorKey(folder);
    }

    // If we already assigned a color to this key, return it
    if (folderColors[colorKey]) {
        return folderColors[colorKey];
    }

    // Otherwise, assign a new color from our palette
    const colorIndex = Object.keys(folderColors).length % colorPalette.length;
    folderColors[colorKey] = colorPalette[colorIndex];
    return folderColors[colorKey];
}

function createBookmarkElement(bookmark, isSearchMode = false) {
    // Create container for the bookmark item and delete button
    const container = document.createElement('div');
    container.className = 'bookmark-item';

    // Create wrapper for bookmark content (title and URL)
    const contentWrapper = document.createElement('div');
    contentWrapper.className = 'bookmark-content';
    container.appendChild(contentWrapper);

    // Create the bookmark link
    const link = document.createElement('a');
    link.href = bookmark.url;
    link.textContent = bookmark.title || bookmark.url;
    link.className = 'bookmark-link';
    contentWrapper.appendChild(link);

    // Create URL display
    const urlDisplay = document.createElement('div');
    urlDisplay.className = 'bookmark-url';
    urlDisplay.textContent = bookmark.url;
    contentWrapper.appendChild(urlDisplay);

    // Only create delete button if not in search mode
    if (!isSearchMode) {
        // Create delete button
        const deleteBtn = document.createElement('button');
        deleteBtn.className = 'delete-button';
        deleteBtn.textContent = '×';
        deleteBtn.setAttribute('aria-label', 'Delete bookmark');
        deleteBtn.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            showDeleteConfirmation(bookmark, e);
        });
        container.appendChild(deleteBtn);
    }

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

    // Reset folder colors on re-render
    folderColors = {};

    // Remove search mode class when returning to normal view
    document.body.classList.remove('search-mode');

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
            const folderColumn = createFolderColumn(folder.title, null, folder.id);

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

function createFolderColumn(title, subtitle = null, folderId = null) {
    const folderColumn = document.createElement('div');
    folderColumn.className = 'folder-column';

    // Apply color if folderId is provided
    if (folderId) {
        const color = getFolderColor(folderId);
        folderColumn.style.backgroundColor = color;
    }

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
            // For direct links, use folder.id to maintain the same color across direct links sections
            const { column, content } = createFolderColumn(folder.title, subtitle, folder.id);

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
            // For subfolders, use the subfolder's ID to get different colors for different subfolders
            const { column, content } = createFolderColumn(folder.title, subfolder.title, subfolder.id);
            processBookmarksInFolder(subfolder.children, content);
            container.appendChild(column);
        } else {
            // This subfolder needs to be split
            splitSubfolderIntoColumns(folder.title, subfolder, container, subfolder.id);
        }
    });
}

function splitSubfolderIntoColumns(parentTitle, subfolder, container, parentFolderId) {
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
        // Use the subfolder's ID for consistent coloring within this subfolder's chunks
        const { column, content } = createFolderColumn(parentTitle, subtitle, subfolder.id);

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

    // Add a class to the body or container to indicate search mode
    document.body.classList.add('search-mode');

    // Reset folder colors for search
    folderColors = {};

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
            const { column, content } = createFolderColumn(pathDisplay, null, folder.id);

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
                        // Add bookmark with search mode enabled
                        const bookmarkElement = createBookmarkElement(item, true);
                        content.appendChild(bookmarkElement);
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

            // Get the top-level folder to use for coloring
            const topFolderId = path.length > 0 ? path[0].id : null;

            // Create folder column with color
            const folderColumn = document.createElement('div');
            folderColumn.className = 'folder-column';

            // Apply color based on top folder
            if (topFolderId) {
                const color = getFolderColor(topFolderId);
                folderColumn.style.backgroundColor = color;
            }

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
                // Create bookmark element with search mode enabled
                const link = createBookmarkElement(bookmark, true);

                // Get the content element that contains the bookmark link
                const content = link.querySelector('.bookmark-content');

                // Highlight the matched text
                highlightText(content, searchTerm);

                folderContent.appendChild(link);
            });

            folderColumn.appendChild(folderContent);
            container.appendChild(folderColumn);
        });
    }
}

// Helper function to get the path of a folder
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
    if (!searchTerm.trim()) return;

    // Find the bookmark link element if we're highlighting a bookmark-content element
    let textElement = element;
    if (element.classList.contains('bookmark-content')) {
        textElement = element.querySelector('.bookmark-link');
    }

    if (!textElement || !textElement.textContent) return;

    const text = textElement.textContent;
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
        textElement.innerHTML = '';
        parts.forEach(part => {
            if (part.isMatch) {
                const highlight = document.createElement('span');
                highlight.style.backgroundColor = 'rgba(255, 255, 100, 0.3)';
                highlight.style.padding = '0 2px';
                highlight.style.borderRadius = '2px';
                highlight.textContent = part.text;
                textElement.appendChild(highlight);
            } else {
                const textNode = document.createTextNode(part.text);
                textElement.appendChild(textNode);
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

    // Check if we're in search mode
    const isSearchMode = document.body.classList.contains('search-mode');

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
        renderBookmarks(); // This will remove the search-mode class
    });

    backHeader.appendChild(backLink);
    backColumn.appendChild(backHeader);
    container.appendChild(backColumn);

    // Get folder path
    const folderPath = getFolderPath(folder);
    const pathDisplay = folderPath.map(f => f.title).join(' > ');

    // Create folder content
    const { column, content } = createFolderColumn(pathDisplay, null, folder.id);

    // Create a custom function to process folder contents with search mode awareness
    function processFolderContentsWithMode(childIds, container) {
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
                    processFolderContentsWithMode(item.children, container);
                }
            } else {
                // This is a bookmark, add it to the container (respecting search mode)
                container.appendChild(createBookmarkElement(item, isSearchMode));
            }
        });
    }

    // Process folder contents with search mode awareness
    if (folder.children && folder.children.length > 0) {
        processFolderContentsWithMode(folder.children, content);
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
function showDeleteConfirmation(bookmark, event) {
    // Store the bookmark to delete
    bookmarkToDelete = bookmark;

    // Close any existing dialog first
    hideDeleteConfirmation();

    // Get the clicked delete button element and its position
    const deleteButton = event.currentTarget;
    const bookmarkItem = deleteButton.parentElement;

    // Get position of the delete button for positioning the dialog
    const buttonRect = deleteButton.getBoundingClientRect();

    // Create confirmation dialog
    const confirmDialog = document.createElement('div');
    confirmDialog.className = 'delete-confirm';
    confirmDialog.id = 'delete-confirm';

    // Position the dialog next to the delete button
    confirmDialog.style.position = 'fixed';
    confirmDialog.style.left = `${buttonRect.right + 10}px`;
    confirmDialog.style.top = `${buttonRect.top - 5}px`;

    // Dialog content
    const title = document.createElement('h3');
    title.textContent = 'Delete Bookmark';

    const message = document.createElement('p');
    message.textContent = `Delete "${bookmark.title}"?`;

    const buttonsContainer = document.createElement('div');
    buttonsContainer.className = 'delete-confirm-buttons';

    const cancelBtn = document.createElement('button');
    cancelBtn.className = 'delete-confirm-cancel';
    cancelBtn.textContent = 'Cancel';
    cancelBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        hideDeleteConfirmation();
    });

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
    deleteBtn.addEventListener('click', (e) => {
        e.stopPropagation();
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

    // Store original button for reference
    confirmDialog.dataset.sourceButtonId = deleteButton.id || Date.now().toString();
    if (!deleteButton.id) {
        deleteButton.id = confirmDialog.dataset.sourceButtonId;
    }

    // Add to document body instead of the bookmark item
    document.body.appendChild(confirmDialog);

    // Focus on the Cancel button by default (safer option)
    cancelBtn.focus();

    // Add keyboard event listener for Escape key
    document.addEventListener('keydown', handleEscapeKey);

    // Add click outside to close
    setTimeout(() => {
        document.addEventListener('click', handleClickOutside);
    }, 10);
}

function hideDeleteConfirmation() {
    // Remove the dialog
    const dialog = document.getElementById('delete-confirm');
    if (dialog) {
        document.body.removeChild(dialog);
    }

    // Remove event listeners
    document.removeEventListener('keydown', handleEscapeKey);
    document.removeEventListener('click', handleClickOutside);

    // Clear bookmarkToDelete
    bookmarkToDelete = null;
}

function handleEscapeKey(e) {
    if (e.key === 'Escape') {
        hideDeleteConfirmation();
    }
}

function handleClickOutside(e) {
    const dialog = document.getElementById('delete-confirm');
    if (dialog && !dialog.contains(e.target) && !e.target.classList.contains('delete-button')) {
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
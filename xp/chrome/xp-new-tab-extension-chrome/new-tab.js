// Global bookmarks store
let allBookmarks = {};
let config = {
    maxEntriesPerColumn: 10
};

function createBookmarkElement(bookmark) {
    const link = document.createElement('a');
    link.href = bookmark.url;
    link.textContent = bookmark.title || bookmark.url;
    link.className = 'bookmark-link';
    return link;
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

    // Find matching bookmarks
    const lowercaseSearch = searchTerm.toLowerCase();
    const matches = Object.values(allBookmarks).filter(item =>
        !item.isFolder && item.title.toLowerCase().includes(lowercaseSearch)
    );

    if (matches.length === 0) {
        const noResults = document.createElement('div');
        noResults.textContent = 'No bookmarks found matching your search.';
        noResults.style.padding = '20px';
        noResults.style.textAlign = 'center';
        container.appendChild(noResults);
        return;
    }

    // Group matches by parent folder
    const folderMatches = {};

    matches.forEach(bookmark => {
        const parentId = bookmark.parentId;
        if (!folderMatches[parentId]) {
            folderMatches[parentId] = [];
        }
        folderMatches[parentId].push(bookmark);
    });

    // Create a results column
    const resultsColumn = document.createElement('div');
    resultsColumn.className = 'folder-column';
    resultsColumn.style.gridColumn = '1 / -1'; // Span all columns

    const resultsHeader = document.createElement('div');
    resultsHeader.className = 'folder-header';
    resultsHeader.textContent = `Search Results: ${matches.length} bookmarks found`;
    resultsColumn.appendChild(resultsHeader);

    const resultsContent = document.createElement('div');
    resultsContent.className = 'folder-content';
    resultsContent.style.display = 'grid';
    resultsContent.style.gridTemplateColumns = 'repeat(auto-fill, minmax(250px, 1fr))';
    resultsContent.style.gap = '10px';
    resultsColumn.appendChild(resultsContent);

    // Add all matches
    matches.forEach(bookmark => {
        const link = createBookmarkElement(bookmark);
        resultsContent.appendChild(link);
    });

    container.appendChild(resultsColumn);
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
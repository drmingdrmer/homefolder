// Global bookmarks store
let allBookmarks = {};

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

    // Create a column for each top-level folder
    topLevelFolders.forEach(folder => {
        // Create folder column
        const folderColumn = document.createElement('div');
        folderColumn.className = 'folder-column';

        // Add folder header
        const folderHeader = document.createElement('div');
        folderHeader.className = 'folder-header';
        folderHeader.textContent = folder.title;
        folderColumn.appendChild(folderHeader);

        // Create folder content container
        const folderContent = document.createElement('div');
        folderContent.className = 'folder-content';
        folderColumn.appendChild(folderContent);

        // Process folder contents
        if (folder.children && folder.children.length > 0) {
            processBookmarksInFolder(folder.children, folderContent);
        }

        // Add column to container
        container.appendChild(folderColumn);
    });
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

document.addEventListener('DOMContentLoaded', () => {
    const searchBox = document.getElementById('searchBox');

    chrome.bookmarks.getTree((bookmarkTreeNodes) => {
        collectAllBookmarks(bookmarkTreeNodes);
        renderBookmarks();
    });

    searchBox.addEventListener('input', (e) => {
        filterBookmarks(e.target.value);
    });
}); 
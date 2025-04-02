function createBookmarkElement(bookmark) {
    const link = document.createElement('a');
    link.href = bookmark.url;
    link.textContent = bookmark.title || bookmark.url;
    return link;
}

function createFolderElement(folder) {
    const folderDiv = document.createElement('div');
    folderDiv.className = 'bookmark-folder';

    const folderTitle = document.createElement('div');
    folderTitle.className = 'folder-title';
    folderTitle.textContent = folder.title;

    folderDiv.appendChild(folderTitle);
    return folderDiv;
}

function renderBookmarks(bookmarkTreeNodes, container) {
    bookmarkTreeNodes.forEach(node => {
        if (node.children) {
            // This is a folder
            const folderElement = createFolderElement(node);
            const folderContainer = document.createElement('div');
            renderBookmarks(node.children, folderContainer);
            folderElement.appendChild(folderContainer);
            container.appendChild(folderElement);
        } else if (node.url) {
            // This is a bookmark
            container.appendChild(createBookmarkElement(node));
        }
    });
}

function filterBookmarks(searchTerm, container) {
    const links = container.getElementsByTagName('a');
    const folders = container.getElementsByClassName('bookmark-folder');

    // First hide all links that don't match
    Array.from(links).forEach(link => {
        const text = link.textContent.toLowerCase();
        const match = text.includes(searchTerm.toLowerCase());
        link.style.display = match ? 'block' : 'none';
    });

    // Then hide folders that have no visible links
    Array.from(folders).forEach(folder => {
        const visibleLinks = folder.getElementsByTagName('a');
        const hasVisibleLinks = Array.from(visibleLinks).some(link => link.style.display !== 'none');
        folder.style.display = hasVisibleLinks ? 'block' : 'none';
    });
}

document.addEventListener('DOMContentLoaded', () => {
    const container = document.getElementById('bookmarks-container');
    const searchBox = document.getElementById('searchBox');

    // Use chrome.tabs API to set focus on our search input
    chrome.tabs.getCurrent(tab => {
        if (tab) {
            chrome.tabs.update(tab.id, { active: true }, () => {
                searchBox.focus();
            });
        }
    });

    chrome.bookmarks.getTree((bookmarkTreeNodes) => {
        renderBookmarks(bookmarkTreeNodes, container);
    });

    searchBox.addEventListener('input', (e) => {
        filterBookmarks(e.target.value, container);
    });
}); 
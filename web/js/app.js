function isDarkMode() {
    return localStorage.theme === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches);
}

function switchTheme() {
    var currentMode = localStorage.theme == 'dark' || document.documentElement.classList.contains('dark');
    setDarkMode(!currentMode);
    try {
        switchThemeDart(!currentMode);
    } catch (_) { }
}
function setDarkMode(isDarkMode) {
    if (isDarkMode) {
        document.documentElement.classList.add('dark')
        localStorage.theme = 'dark'
    } else {
        document.documentElement.classList.remove('dark')
        localStorage.theme = 'light'
    }
}

try {
    if (isDarkMode()) {
        document.documentElement.classList.add('dark')
    } else {
        document.documentElement.classList.remove('dark')
    }
} catch (_) { }
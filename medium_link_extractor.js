/**
 * Continuous Scrolling Script with File Download Capability (TXT and JSON).
 * To stop the scrolling and download the files, type 'stopScript()' in the console and press Enter.
 */

(function() {
    // --- Configuration and State ---
    const SCROLL_INTERVAL_MS = 100; 
    const SCROLL_DISTANCE = window.innerHeight / 4; 
    const ARTICLE_SELECTOR = 'article[data-testid="post-preview"]';
    
    let scrollTimer = null;
    let previousHeight = 0;
    
    // --- Utility function to trigger file download ---
    function downloadFile(filename, text, mimeType) {
        const element = document.createElement('a');
        element.setAttribute('href', `data:${mimeType};charset=utf-8,${encodeURIComponent(text)}`);
        element.setAttribute('download', filename);

        element.style.display = 'none';
        document.body.appendChild(element);

        element.click();

        document.body.removeChild(element);
        console.log(`\n⬇️ Download initiated for: **${filename}**`);
    }

    // --- Core Scrolling Function ---
    function autoScroll() {
        const newHeight = document.body.scrollHeight;

        if (newHeight === previousHeight) {
            // Log a warning if page height hasn't changed.
            // console.log('🛑 INFO: Content loading seems stalled. Continuing scroll...');
        } else {
            previousHeight = newHeight;
        }

        window.scrollBy(0, SCROLL_DISTANCE);
    }
    
    // --- Article Data Extraction and File Generation ---
    function extractArticleData() {
        const articles = document.querySelectorAll(ARTICLE_SELECTOR);
        const articleData = [];
        const baseUrl = window.location.origin;

        // 1. Extract Data
        articles.forEach((article, index) => {
            const titleElement = article.querySelector('h2');
            const linkElement = article.querySelector('a[rel="noopener follow"][href*="/p/"], a[rel="noopener follow"][href^="/"]');
            
            const title = titleElement ? titleElement.innerText.trim() : 'Title Not Found';
            let link = linkElement ? linkElement.getAttribute('href') : 'Link Not Found';

            if (link && link.startsWith('/') && link !== 'Link Not Found') {
                link = baseUrl + link;
            }

            articleData.push({
                number: index + 1,
                title: title,
                link: link
            });
        });
        
        // --- 2. Generate File Content ---
        
        // A. JSON Format
        const jsonContent = JSON.stringify(articleData, null, 2); // null, 2 for pretty printing
        
        // B. TXT Format
        let txtContent = `InfoSec Write-ups (Bug Bounty) Article List\n`;
        txtContent += `Total Articles Found: ${articles.length}\n`;
        txtContent += "=========================================\n\n";
        
        articleData.forEach(item => {
            txtContent += `Article #${item.number}\n`;
            txtContent += `Title: ${item.title}\n`;
            txtContent += `Link: ${item.link}\n`;
            txtContent += `-----------------------------------------\n`;
        });
        
        // --- 3. Trigger Downloads ---
        downloadFile('article_list.json', jsonContent, 'application/json');
        downloadFile('article_list.txt', txtContent, 'text/plain');

        // --- 4. Console Output ---
        console.log('\n--- ** FINAL RESULTS: InfoSec Write-ups (Bug Bounty) ** ---');
        console.log(`\n**Total Unique Articles Counted: ${articles.length}**\n`);
        console.table(articleData);
        console.log('=================================================');
        console.log('✅ Extraction complete! Check your Downloads folder for the files.');
        console.log('=================================================');
    }

    // --- Manual Stop Function (Global) ---
    window.stopScript = function() {
        if (scrollTimer) {
            clearInterval(scrollTimer);
            scrollTimer = null; // Clear the timer ID
            console.log('\n✅ **SCROLLING STOPPED MANUALLY.** Proceeding to data extraction and file generation...');
            extractArticleData();
        } else {
            console.warn('⚠️ Scrolling is already stopped or has not been started. Running extraction only...');
            extractArticleData();
        }
    };
    
    // --- Start the Scroll Loop ---
    if (!scrollTimer) {
        scrollTimer = setInterval(autoScroll, SCROLL_INTERVAL_MS);
        console.log(`\n**🚀 SCROLLING STARTED.** Scrolling every ${SCROLL_INTERVAL_MS}ms.`);
        console.log('To stop and download results, type: **stopScript()** in the console and press Enter.');
    } else {
        console.log('The auto-scroll script is already running.');
    }
})();
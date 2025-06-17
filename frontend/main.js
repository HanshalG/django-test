// Import ReScript modules
import './styles.css';
import { setupCounter } from './Counter.bs.js';
import { fetchComments, submitComment } from './comment_handler.res.js';
import { createRoot } from 'react-dom/client';
import Counter from './Counter.res';

// Render the ReScript React component
const container = document.getElementById('counter-app');
if (container) {
  const root = createRoot(container);
  root.render(<Counter />);
}

// Initialize the counter
setupCounter();

// Comment functionality
const commentList = document.getElementById('comment-list');
const commentButton = document.getElementById('submit-comment');

// Only run comment-related code if the elements exist
if (commentList && commentButton) {
    // Set up event listener for comments
    commentButton.addEventListener('click', async () => {
        const content = document.getElementById('comment-content')?.value.trim();
        if (content) {
            await submitComment(postId, content, commentList);
            const textarea = document.getElementById('comment-content');
            if (textarea) textarea.value = ''; // Clear the textarea
        }
    });

    // Initial fetch of comments if we have a postId
    if (typeof postId !== 'undefined') {
        fetchComments(postId, commentList);
    }
}

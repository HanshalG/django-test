import { fetchComments, submitComment } from './comment_handler.res.js';
import './styles.css';

// Get the post ID from the template
const commentList = document.getElementById('comment-list');
const commentButton = document.getElementById('submit-comment');

// Set up event listener
commentButton.addEventListener('click', async () => {
    const content = document.getElementById('comment-content').value.trim();
    if (content) {
        await submitComment(postId, content, commentList);
        document.getElementById('comment-content').value = ''; // Clear the textarea
    }
});

// Initial fetch of comments
fetchComments(postId, commentList);

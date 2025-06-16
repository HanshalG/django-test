const postId = window.postId; // We'll set this via a template variable below
const commentList = document.getElementById('comment-list');

function fetchComments() {
    fetch(`/post/${postId}/comments/`)
        .then(response => response.json())
        .then(data => {
            commentList.innerHTML = '';
            data.forEach(comment => {
                const li = document.createElement('li');
                li.textContent = `${comment.author_username} said: ${comment.body}`;
                commentList.appendChild(li);
            });
        })
        .catch(error => console.error(error));
}

function submitComment() {
    const content = document.getElementById('comment-content').value;

    fetch(`/post/${postId}/comments/`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': getCookie('csrftoken')
        },
        body: JSON.stringify({ body: content })
    })
    .then(response => {
        if (response.ok) {
            document.getElementById('comment-content').value = '';
            fetchComments();
        } else {
            alert('Failed to post comment.');
        }
    });
}

function getCookie(name) {
    let cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        const cookies = document.cookie.split(';');
        for (let cookie of cookies) {
            const c = cookie.trim();
            if (c.startsWith(name + '=')) {
                cookieValue = decodeURIComponent(c.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}

// Expose submitComment so it can be used on button onclick
window.submitComment = submitComment;

// Fetch comments on load
fetchComments();

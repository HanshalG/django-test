%%raw(`
export async function fetchComments(postId, commentList) {
    try {
        const response = await fetch(`/post/${postId}/comments/`);
        if (!response.ok) throw new Error('Failed to fetch comments');
        
        const data = await response.json();
        commentList.innerHTML = '';
        data.forEach(comment => {
            const li = document.createElement('li');
            li.textContent = `${comment.author_username || 'Anonymous'}: ${comment.body}`;
            commentList.appendChild(li);
        });
    } catch (error) {
        console.error('Error fetching comments:', error);
        commentList.innerHTML = '<li>Error loading comments. Please refresh the page.</li>';
    }
}

export async function submitComment(postId, content, commentList) {
    try {
        const response = await fetch(`/post/${postId}/comments/`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': getCookie('csrftoken')
            },
            body: JSON.stringify({ body: content })
        });

        if (!response.ok) {
            throw new Error('Failed to post comment');
        }

        // Refresh comments after successful submission 
        await fetchComments(postId, commentList);
        return true;
    } catch (error) {
        console.error('Error submitting comment:', error);
        alert('Failed to post comment. Please try again.');
        return false;
    }
}

function getCookie(name) {
    let cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        const cookies = document.cookie.split(';');
        for (const cookie of cookies) {
            const c = cookie.trim();
            if (c.startsWith(name + '=')) {
                cookieValue = decodeURIComponent(c.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}
`)

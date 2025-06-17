open Webapi.Dom

// Helper: getCookie function to get CSRF token
let getCookie = (name: string): option<string> => {
  switch Document.asHtmlDocument(document) {
    | None => None
    | Some(doc) => {
        let cookieStr = doc->HtmlDocument.cookie
        let matchingCookies = cookieStr
          ->String.split(";")
          ->Belt.Array.keep(c => String.trim(c)->String.startsWith(name ++ "="))
        
        switch Belt.Array.get(matchingCookies, 0) {
          | None => None
          | Some(cookie) => {
              let trimmedCookie = String.trim(cookie)
              let len = String.length(name)
              Some(decodeURIComponent(String.substring(trimmedCookie, ~start=len + 1, ~end=String.length(trimmedCookie))))
            }
        }
      }
  }
}

// Type definitions for the comment data
type comment = {
  author_username: option<string>,
  body: string,
}

// External bindings for DOM and Fetch API
@val external fetch: string => promise<'response> = "fetch"
@send external json: 'response => promise<array<comment>> = "json"
@get external ok: 'response => bool = "ok"

@set external setTextContent: (Dom.element, string) => unit = "textContent"
@set external setInnerHTML: (Dom.element, string) => unit = "innerHTML"
@send external appendChild: (Dom.element, Dom.element) => unit = "appendChild"

@send external error: ('a, string, 'b) => unit = "error"
@val external console: 'a = "console"

let fetchComments = async (postId, commentList) => {
  try {
    let response = await fetch("/post/" ++ postId ++ "/comments/")
    
    if !response->ok {
      %raw(`throw new Error("Failed to fetch comments")`)
    }
    
    let data = await response->json
    commentList->Element.setInnerHTML("")
    
    data->Belt.Array.forEach(comment => {
      let li = document->Document.createElement("li")
      let authorName = switch comment.author_username {
        | Some(username) => username
        | None => "Anonymous"
      }
      li->Element.setTextContent(authorName ++ ": " ++ comment.body)
      commentList->Element.appendChild(~child=li)
    })
  } catch {
    | _ => {
        console->error("Error fetching comments:", %raw(`arguments[0]`))
        commentList->Element.setInnerHTML("<li>Error loading comments. Please refresh the page.</li>")
      }
  }
}


%%raw(`

export async function submitComment(postId, content, commentList) {
    try {
        const response = await fetch('/post/' + postId + '/comments/', {
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
`)

open Webapi.Dom
open Webapi
open Promise

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

type comment = {
  author_username: option<string>,
  body: string,
}

@send external error: ('a, string, 'b) => unit = "error"
@val external console: 'a = "console"
@val external alert: string => unit = "alert"

let fetchComments = (postId, commentList) => {
  Fetch.fetch("/post/" ++ postId ++ "/comments/")
  ->then(Fetch.Response.json)
  ->then(data => {commentList->Element.setInnerHTML("")
    switch data->Js.Json.decodeArray {
      | Some(comments) => {
          comments->Belt.Array.forEach(comment => {
            let li = document->Document.createElement("li")
            let authorName = switch comment->Js.Json.decodeObject {
            | Some(commentDict) => 
                switch (commentDict->Js.Dict.get("author_username")) {
                | Some(username) => 
                    switch (username->Js.Json.decodeString) {
                    | Some(name) => name
                    | None => "Anonymous"
                    }
                | None => "Anonymous"
                }
            | None => "Anonymous"
          }
          let body = switch comment->Js.Json.decodeObject {
            | Some(commentDict) => 
                switch (commentDict->Js.Dict.get("body")) {
                | Some(body) => 
                    switch (body->Js.Json.decodeString) {
                    | Some(body) => body
                    | None => ""
                    }
                | None => ""
                }
            | None => ""
          }
            li->Element.setTextContent(authorName ++ ": " ++ body)
            commentList->Element.appendChild(~child=li)
          })
    resolve()
      }
      | None => {
          commentList->Element.setInnerHTML("<li>Error loading comments. Please refresh the page.</li>")
          resolve()
      }
    }
  })
  ->catch(error => {
    commentList->Element.setInnerHTML("<li>Error loading comments. Please refresh the page.</li>")
    resolve()
  })
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

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
  let fetchComments = Fetch.fetch("/post/" ++ postId ++ "/comments/")
  ->then(Fetch.Response.json)
  ->then(json => { commentList->Element.setInnerHTML("");
    Js.Json.decodeArray(json)->resolve})
  ->then(opt => opt->Belt.Option.getExn->resolve)
  
  fetchComments->then(array => {
    array->Belt.Array.forEach(comment => {
      let li = document->Document.createElement("li")
      let commentDict = comment->Js.Json.decodeObject->Belt.Option.getExn
      let body = commentDict->Js.Dict.get("body")->Belt.Option.getExn->Js.Json.decodeString->Belt.Option.getExn
      let authorName = commentDict->Js.Dict.get("author_username")->Belt.Option.getExn->Js.Json.decodeString->Belt.Option.getExn
      li->Element.setTextContent(authorName ++ ": " ++ body)
      commentList->Element.appendChild(~child=li)
    })->resolve
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

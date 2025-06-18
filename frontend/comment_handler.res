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

let submitComment = (postId: string, content: string, commentList: Dom.Element.t): promise<bool> => {
  let headers = Js.Dict.empty()
  Js.Dict.set(headers, "Content-Type", "application/json")
  
  switch getCookie("csrftoken") {
  | Some(token) => Js.Dict.set(headers, "X-CSRFToken", token)
  | None => ()
  }

  let body = Js.Dict.empty()
  Js.Dict.set(body, "body", Js.Json.string(content))

  Fetch.fetchWithInit(
    "/post/" ++ postId ++ "/comments/",
    Fetch.RequestInit.make(
      ~method_=Post,
      ~headers=Fetch.HeadersInit.makeWithDict(headers),
      ~body=Fetch.BodyInit.make(Js.Json.stringify(Js.Json.object_(body))),
      ()
    )
  )
  ->then(response =>
    if Fetch.Response.ok(response) {
      fetchComments(postId, commentList)->then(_ => resolve(true))
    } else {
      reject(Js.Exn.raiseError("Failed to post comment"))
    }
  )
  ->catch(err => {
    console->error("Error submitting comment:", err)
    alert("Failed to post comment. Please try again.")
    resolve(false)
  })
}

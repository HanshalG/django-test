// Counter.res

// Simple counter implementation using React

// Counter component using React
@react.component
let make = () => {
  let (count, setCount) = React.useState(() => 0)

  let increment = _ => setCount(prev => prev + 1)
  let decrement = _ => setCount(prev => prev - 1)

  <div className="counter">
    <h2>{"ReScript React Counter"->React.string}</h2>
    <div className="counter-display">
      {count->Belt.Int.toString->React.string}
    </div>
    <div className="counter-buttons">
      <button onClick=decrement>{"Decrement"->React.string}</button>
      <button onClick=increment>{"Increment"->React.string}</button>
    </div>
  </div>
}

// Export the component as default
export default make

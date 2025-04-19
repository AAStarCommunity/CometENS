// src/App.jsx
// import logo from './logo.svg';
import ENSDemo from './ENSDemo';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        {/* <img src={logo} className="App-logo" alt="logo" /> */}
        <p>
          Edit <code>src/App.jsx</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="[https://reactjs.org](https://reactjs.org)"
          target="_blank"
          rel="noopener noreferrer"
        >
          CometENS Demo
        </a>
      </header>
      <ENSDemo />
    </div>
  );
}

export default App;
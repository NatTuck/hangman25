import React, { useState, useEffect } from 'react';
import { createRoot } from 'react-dom/client';
import $ from 'cash-dom';

import socket from "./user_socket";

let channel = null;

const defaultState = {
  letters_view: ["_", "_", "_"],
  bad_guess: 0,
  remaining_letters: [],
};

function Hangman({ name }) {
  const [state, setState] = useState(defaultState);

  useEffect(() => {
    channel = socket.channel("game:" + name);
    channel.join()
      .receive("ok", (resp) => {
        console.log("Joined successfully:", resp);
        setState(resp.view);
      });
  }, []);

  let remaining = state.remaining_letters;

  function click_guess(ev, letter) {
    ev.preventDefault();
    channel.push("guess", { letter })
      .receive("ok", setState);
  }

  let guess_links = Array.from(remaining).map((letter) => (
    <a href="#" key={letter} onClick={(ev) => click_guess(ev, letter)}>{letter}</a>
  ));

  let bad_guesses = state.bad_guesses;

  function reset(ev) {
    ev.preventDefault();
    channel.push("reset", {})
      .receive("ok", setState);
  }

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-200">
      <div className="bg-white p-8 rounded-lg shadow-lg text-center">
        <p className="text-4xl mb-4 font-bold">Hangman: {name}</p>
        <p className="text-3xl tracking-widest mb-6">{state.letters_view}</p>
        <p className="text-xl">Bad guesses: {bad_guesses}</p>
        <p className="text-xl">{guess_links}</p>
        <p className="mt-6">
          <button
            onClick={reset}
            className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-full transition-colors duration-300 ease-in-out"
          >
            Reset Game
          </button>
        </p>
      </div>
    </div>
  );
}

function Game() {
  const [name, setName] = useState(null);

  function join_game(ev) {
    ev.preventDefault();
    let name = document.getElementById('game-name').value;
    setName(name);
  }

  if (name) {
    return <Hangman name={name} />;
  }

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-200">
      <div className="bg-white p-8 rounded-lg shadow-lg text-center">
        <p className="text-4xl mb-4 font-bold">Hangman</p>
        <p>Game Name: <input className="bg-blue-100" type="text" id="game-name" /></p>
        <p className="mt-6">
          <button
            onClick={join_game}
            className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-full transition-colors duration-300 ease-in-out"
          >
            Join Game
          </button>
        </p>
      </div>
    </div>
  );
}


function init() {
  var root_div = document.getElementById('hangman-root');
  if (!root_div) {
    return;
  }

  const root = createRoot(root_div);
  root.render(<Game />);
}

$(init);

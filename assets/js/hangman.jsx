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

function Hangman({ names }) {
  const { game, user } = names;
  const [state, setState] = useState(defaultState);
  const [cooldown, setCooldown] = useState(null);

  useEffect(() => {
    channel = socket.channel("game:" + game, { user: user });
    channel.on("update", (view) => {
      console.log("Got update", view);
      setState(view);
    });
    channel.join()
      .receive("ok", (resp) => {
        console.log("Joined successfully:", resp);
        setState(resp.view);
      });

  }, []);

  let remaining = state.remaining_letters;

  function count_down(nn) {
    console.log("nn", nn);
    if (nn > 0) {
      console.log("decr");
      setCooldown(nn - 1);
      window.setTimeout(() => count_down(nn - 1), 1000);
    }
    else {
      console.log("null");
      setCooldown(null);
    }
  }

  function click_guess(ev, letter) {
    ev.preventDefault();
    channel.push("guess", { letter })
      .receive("ok", (view) => {
        setCooldown(5);
        window.setTimeout(() => count_down(5), 1000);
        setState(view);
      });
  }

  let all_letters = [
    "QWERTYUIOP",
    "ASDFGHJKL",
    "ZXCVBNM"
  ];

  function create_button(letter, remaining) {
    let active_class = "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 m-1 rounded transition-colors duration-300 ease-in-out";
    let inactive_class = "bg-gray-500 text-white font-bold py-2 px-4 m-1 rounded transition-colors duration-300 ease-in-out";

    if (remaining.includes(letter)) {
      return (
        <button
          key={letter}
          onClick={(ev) => click_guess(ev, letter)}
          className={active_class}
        >
          {letter}
        </button>
      );
    }
    return (
      <button
        key={letter}
        className={inactive_class}
      >
        {letter}
      </button>
    );
  }

  let rows = all_letters.map((row, rowIndex) => (
    <div key={rowIndex}>
      {Array.from(row).map((letter) => create_button(letter.toLowerCase(), remaining))}
    </div>
  ));

  let guess_links_or_cooldown = rows;
  if (cooldown) {
    guess_links_or_cooldown = cooldown;
  }

  let bad_guesses = state.bad_guesses;

  function reset(ev) {
    ev.preventDefault();
    channel.push("reset", {})
      .receive("ok", setState);
  }

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-200">
      <div className="bg-white p-8 rounded-lg shadow-lg text-center">
        <p className="text-xl">User: {names.user}</p>
        <p className="text-4xl mb-4 font-bold">Hangman: {game}</p>
        <p className="text-3xl tracking-widest mb-6">{state.letters_view}</p>
        <p className="text-xl">Bad guesses: {bad_guesses}</p>
        <p className="text-xl">{guess_links_or_cooldown}</p>
        <p className="text-xl">Last action: {state.last_action}</p>
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
  const [names, setNames] = useState({ user: null, game: null });

  function join_game(ev) {
    ev.preventDefault();
    let user = document.getElementById('player-name').value;
    let game = document.getElementById('game-name').value;
    setNames({ user, game });
  }

  if (names.user && names.game) {
    return <Hangman names={names} />;
  }

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-200">
      <div className="bg-white p-8 rounded-lg shadow-lg text-center">
        <p className="text-4xl mb-4 font-bold">Hangman</p>
        <p>Player Name: <input className="bg-blue-100" type="text" id="player-name" /></p>
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

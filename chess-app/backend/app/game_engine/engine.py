from dataclasses import dataclass, field
from typing import List, Any

START_BOARD = [
    ["r","n","b","q","k","b","n","r"],
    ["p"]*8,
    ["."]*8,
    ["."]*8,
    ["."]*8,
    ["."]*8,
    ["P"]*8,
    ["R","N","B","Q","K","B","N","R"],
]

@dataclass
class Game:
    board: List[List[str]] = field(default_factory=lambda: [row.copy() for row in START_BOARD])
    turn: str = "white"
    history: List[str] = field(default_factory=list)

    def coord_to_idx(self, coord: str):
        if not coord or len(coord) < 2:
            return None
        file = ord(coord[0]) - ord('a')
        rank = 8 - int(coord[1])
        return rank, file

    def is_valid_move(self, frm: str, to: str):
        f = self.coord_to_idx(frm)
        t = self.coord_to_idx(to)
        if f is None or t is None:
            return False, "bad coords"
        fr_piece = self.board[f[0]][f[1]]
        if fr_piece == ".":
            return False, "no piece"
        return True, "ok"

    def make_move(self, frm: str, to: str):
        f = self.coord_to_idx(frm)
        t = self.coord_to_idx(to)
        piece = self.board[f[0]][f[1]]
        self.board[t[0]][t[1]] = piece
        self.board[f[0]][f[1]] = "."
        self.history.append(f"{frm}{to}")
        self.turn = "black" if self.turn == "white" else "white"

    def get_state(self) -> Any:
        return {
            "board": self.board,
            "turn": self.turn,
            "history": self.history,
        }

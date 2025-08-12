# Copilot Instructions for SRChess

- All chess logic (move validation, rules, turn order) must be server-side. The frontend only dispatches actions and renders state from the server.
- Use React functional components and hooks (`useState`, `useEffect`, `useContext`).
- Centralize all game state in `GameContext`. Do not duplicate state in components.
- All user actions (move, resign, chat, rules change) must dispatch to the server via WebSocket.
- Do not use chess.js or similar libraries unless explicitly requested.
- Use absolute imports with aliases (e.g., `@contexts/GameContext`).
- UI should be styled with Tailwind CSS or minimal CSS modules.
- All comments must be in Russian and explain "why", not "what".
- All API and WebSocket URLs must use `localhost` for development.
- Do not add business logic to UI components; delegate to the server.
- Follow the architectural diagrams and component structure described in the documentation.

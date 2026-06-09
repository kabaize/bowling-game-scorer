import { useMemo, useState } from "react";
import { fetchScore } from "./api/scoreClient";
import { generateRandomCompleteGameRolls, rollsToString } from "./utils/randomRollsGenerator";
import "./App.css";

function parseRolls(input) {
  const tokens = input
    .split(/[\s,]+/)
    .map((t) => t.trim())
    .filter(Boolean);

  return tokens.map((token) => {
    if (token === "X" || token === "/") return token;
    const num = Number(token);
    if (Number.isNaN(num)) return token;
    return num;
  });
}

export default function App() {
  const [rollsText, setRollsText] = useState(
    "X,7,/,9,0,X,0,8,8,/,0,6,X,X,X,8,1"
  );
  const [result, setResult] = useState(null);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const rollsPreview = useMemo(() => parseRolls(rollsText), [rollsText]);

  async function handleScore() {
    setLoading(true);
    setError("");
    setResult(null);

    try {
      const data = await fetchScore(rollsPreview);
      setResult(data);
    } catch (e) {
      setError(e?.message || "Something went wrong");
    } finally {
      setLoading(false);
    }
  }

  function handleClear() {
    setRollsText("");
    setResult(null);
    setError("");
  }

  function handleRandomGame() {
    const rolls = generateRandomCompleteGameRolls();
    setRollsText(rollsToString(rolls));
    setResult(null);
    setError("");
  }

  return (
    <div className="pageContents">
      <div className="container">
        <div className="header">
          <h1 className="title">Bowling Scorer</h1>
          <p className="subtitle">
            Enter rolls separated by commas/spaces. Use <b>X</b> for strike and{" "}
            <b>/</b> for spare.
          </p>
        </div>

        <div className="card">
          <label className="label">Rolls</label>
          <textarea
            className="textarea"
            value={rollsText}
            onChange={(e) => setRollsText(e.target.value)}
            rows={3}
            placeholder="Example: X,7,/,9,0,X,0,8,8,/,0,6,X,X,X,8,1"
          />

          <div className="row" style={{ marginTop: 12 }}>
            <button
              className="button buttonPrimary"
              onClick={handleScore}
              disabled={loading || rollsPreview.length === 0}
            >
              {loading ? "Scoring..." : "Score"}
            </button>

            <button className="button" onClick={handleRandomGame} disabled={loading}>
              Random Game
            </button>

            <button className="button" onClick={handleClear} disabled={loading}>
              Clear
            </button>
          </div>

          <div className="codeBlock" aria-label="parsed-rolls-preview">
            <div className="codeTitle">
              Parsed rolls preview
            </div>
            <code>{JSON.stringify(rollsPreview)}</code>
          </div>

          {error && (
            <div className="bannerError">
              <b>Error -</b> {error}
            </div>
          )}
        </div>

        {result && (
          <div className="card" style={{ marginTop: 16 }}>
            <div className="resultsHeader">
              <h2 style={{ margin: 0 }}>Results</h2>
              <div className="total">
                Total: <span>{result.total ?? "—"}</span>
              </div>
            </div>

            <div className="grid">
              {result.frames.map((frameScore, idx) => {
                const incomplete = frameScore === null;
                return (
                  <div
                    key={idx}
                    className={`frameCard ${incomplete ? "frameIncomplete" : ""}`}
                  >
                    <div className="frameLabel">Frame {idx + 1}</div>
                    <div className="frameScore">{frameScore ?? "—"}</div>
                  </div>
                );
              })}
            </div>

            <div className="hint" style={{ marginTop: 10 }}>
              Incomplete frames show <b>—</b>.
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

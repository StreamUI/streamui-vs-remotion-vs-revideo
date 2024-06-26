import React from "react";
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  Sequence,
} from "remotion";
import { useState, useEffect, useCallback } from "react";
import { fetchNewPeople } from "./fetchPeople";
import { Person } from "./types";
import { predictWin, rating } from "openskill";

const CountdownBar: React.FC<{ progress: number }> = ({ progress }) => {
  const { width, height } = useVideoConfig();
  const barWidth = interpolate(progress, [0, 1], [width, 0]);

  return (
    <div
      style={{
        position: "absolute",
        top: height / 2 + 30,
        left: 0,
        width: "100%",
        height: 50,
        backgroundColor: "white",
      }}
    >
      <div
        style={{
          width: barWidth,
          height: "100%",
          backgroundColor: "green",
        }}
      ></div>
    </div>
  );
};

const ThisOrThatRound: React.FC<{
  person1: Person;
  person2: Person;
  showResults: boolean;
}> = ({ person1, person2, showResults }) => {
  const { width, height } = useVideoConfig();

  const person1Score = rating({
    mu: person1.openskill_mu,
    sigma: person1.openskill_sigma,
  });

  const person2Score = rating({
    mu: person2.openskill_mu,
    sigma: person2.openskill_sigma,
  });

  const predictions = predictWin([[person1Score], [person2Score]]);
  const [probability1, probability2] = predictions;
  const percent1 = Math.round(probability1 * 100);
  const percent2 = Math.round(probability2 * 100);

  const higherPercent = percent1 >= percent2 ? percent1 : percent2;

  return (
    <AbsoluteFill style={{ backgroundColor: "white" }}>
      <img
        src={person1.image}
        alt="Top Image"
        style={{
          width: "100%",
          height: (height - 0) / 2,
          objectFit: "cover",
          position: "absolute",
          top: 0,
        }}
      />
      {showResults && (
        <div
          style={{
            position: "absolute",
            top: height / 4 - 200,
            left: "50%",
            transform: "translateX(-50%)",
            textAlign: "center",
            backgroundColor: "rgba(0, 0, 0, 0.8)",
            color: percent1 === higherPercent ? "green" : "red",
            padding: "10px 20px",
            fontSize: 300,
            borderRadius: 50,
            fontWeight: "bolder",
          }}
        >
          {percent1}%
        </div>
      )}
      <div
        style={{
          position: "absolute",
          top: height / 3 + 150,
          left: "50%",
          width: "80%",
          transform: "translateX(-50%)",
          textAlign: "center",
          backgroundColor: "rgba(255, 255, 255, 0.7)",
          color: "black",
          padding: "10px 20px",
          fontSize: 55,
          fontWeight: "bolder",
        }}
      >
        {person1.flag} {person1.name}
      </div>
      <img
        src={person2.image}
        alt="Bottom Image"
        style={{
          width: "100%",
          height: (height - 0) / 2,
          objectFit: "cover",
          position: "absolute",
          bottom: 0,
        }}
      />
      {showResults && (
        <div
          style={{
            position: "absolute",
            top: (3 * height) / 4 - 170,
            left: "50%",
            transform: "translateX(-50%)",
            textAlign: "center",
            backgroundColor: "rgba(0, 0, 0, 0.8)",
            borderRadius: 50,
            color: percent2 === higherPercent ? "green" : "red",
            padding: "10px 20px",
            fontSize: 300,
            fontWeight: "bolder",
          }}
        >
          {percent2}%
        </div>
      )}
      <div
        style={{
          position: "absolute",
          top: (3 * height) / 4 + 300,
          left: "50%",
          width: "80%",
          transform: "translateX(-50%)",
          textAlign: "center",
          backgroundColor: "rgba(255, 255, 255, 0.7)",
          color: "black",
          padding: "10px 20px",
          fontSize: 55,
          fontWeight: "bolder",
        }}
      >
        {person2.flag} {person2.name}
      </div>
      <div
        style={{
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          position: "absolute",
          top: height / 2 - 90,
          left: 0,
          height: "7%",
          width: "100%",
          textAlign: "center",
          backgroundColor: "black",
          fontSize: 76,
          fontWeight: "bolder",
          color: "pink",
        }}
      >
        Who's hotter?
      </div>
      <div
        style={{
          position: "absolute",
          bottom: 0,
          width: "100%",
          textAlign: "center",
          backgroundColor: "black",
          padding: "20px",
          fontSize: 45,
          fontWeight: "bold",
          color: "white",
        }}
      >
        Vote @ www.mogged.ai
      </div>
    </AbsoluteFill>
  );
};

export const ThisOrThat: React.FC = ({ people }) => {
  const { fps, durationInFrames } = useVideoConfig();

  const [currentPeople, setCurrentPeople] = useState([people[0], people[1]]);
  const [audioSrc, setAudioSrc] = useState<string | null>(null);

  // const [showResults, setShowResults] = useState(false);
  const [framesInRound, setFramesInRound] = useState(0);
  // const [currentRound, setCurrentRound] = useState(0);

  const frame = useCurrentFrame();
  const roundDuration = 3 * fps;
  const resultsDuration = 1.5 * fps;
  const cycleDuration = roundDuration + resultsDuration;

  const currentRound = Math.floor(frame / cycleDuration);
  const currentFrameInRound = frame % cycleDuration;
  const progress = Math.min(currentFrameInRound / roundDuration, 1);

  // const [progress, setProgress] = useState(0);

  const [paused, setPaused] = useState(false);

  const currentFrame = frame % cycleDuration;
  const progressValue = Math.min(currentFrame / roundDuration, 1);

  const person1 = people[currentRound * 2];
  const person2 = people[currentRound * 2 + 1];

  const showResults = currentFrameInRound >= roundDuration;

  const nextRound = (currentRound + 1) % (people.length / 2);
  const nextPerson1 = people[(nextRound * 2) % people.length];
  const nextPerson2 = people[(nextRound * 2 + 1) % people.length];

  const preloadImages = (images: string[]) => {
    images.forEach((image) => {
      const img = new Image();
      img.src = image;
    });
  };

  useEffect(() => {
    preloadImages([
      person1.image,
      person2.image,
      nextPerson1.image,
      nextPerson2.image,
    ]);
  }, [person1, person2, nextPerson1, nextPerson2]);

  return (
    <AbsoluteFill style={{ backgroundColor: "white" }}>
      <ThisOrThatRound
        person1={person1}
        person2={person2}
        showResults={showResults}
      />
      <CountdownBar progress={progress} />
      {audioSrc && !showResults && <audio src={audioSrc} autoPlay />}
    </AbsoluteFill>
  );
};

import { Composition, CalculateMetadataFunction } from "remotion";
import { ThisOrThat } from "./ThisOrThat";
import { fetch100People } from "./fetchPeople";
import { Person } from "./types";

const calculateThisOrThatMetadata: CalculateMetadataFunction<{
  people: Person[];
}> = async ({ props }) => {
  console.log("fetching people");
  const people = await fetch100People();
  return {
    props: {
      ...props,
      people,
    },
  };
};

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="Mogged"
        component={ThisOrThat}
        durationInFrames={500}
        fps={30}
        width={1080}
        height={1920}
        defaultProps={{
          people: [],
        }}
        calculateMetadata={calculateThisOrThatMetadata}
      />
    </>
  );
};

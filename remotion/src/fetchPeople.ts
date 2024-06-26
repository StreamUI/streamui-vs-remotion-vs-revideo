import sql from "./db";
import { predictWin, rating } from "openskill";
import getFlagForEthnicity from "./ethnicityToFlag";
import { Person } from "./types";

export const fetchNewPeople = async () => {
  try {
    const people = await sql`
      SELECT name, image_url, ethnicity, openskill_mu, openskill_sigma
      FROM people
      WHERE gender = 'Female'
      ORDER BY RANDOM()
      LIMIT 2
    `;
    const [person1, person2] = people;

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

    return {
      person1: {
        name: person1.name,
        image: person1.image_url + "?class=mobile",
        percent: Math.round(probability1 * 100),
        ethnicity: person1.ethnicity,
        flag: getFlagForEthnicity(person1.ethnicity),
      },
      person2: {
        name: person2.name,
        image: person2.image_url + "?class=mobile",
        percent: Math.round(probability2 * 100),
        ethnicity: person2.ethnicity,
        flag: getFlagForEthnicity(person2.ethnicity),
      },
    };
  } catch (error) {
    console.error("Error fetching new people:", error);
    throw error;
  }
};

export const fetch100People = async (): Promise<Person[]> => {
  try {
    const people = await sql`
      SELECT name, image_url, ethnicity, openskill_mu, openskill_sigma
      FROM people
      WHERE gender = 'Female'
      ORDER BY RANDOM()
      LIMIT 100
    `;

    console.log("people", people.length);

    return people.map((person) => ({
      name: person.name,
      image: person.image_url + "?class=mobile",
      flag: getFlagForEthnicity(person.ethnicity),
      ethnicity: person.ethnicity,
      openskill_mu: person.openskill_mu,
      openskill_sigma: person.openskill_sigma,
    }));
  } catch (error) {
    console.error("Error fetching people:", error);
    throw error;
  }
};

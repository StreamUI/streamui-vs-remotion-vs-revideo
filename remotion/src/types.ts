// src/types.ts
export type Person = {
  name: string;
  image: string;
  flag: string;
  ethnicity: string;
  openskill_mu: number;
  openskill_sigma: number;
};

export type FetchPeopleResponse = {
  person1: Person;
  person2: Person;
};

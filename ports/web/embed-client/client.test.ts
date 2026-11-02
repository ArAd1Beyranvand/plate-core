import { readFileSync } from "node:fs";
import { expect, test } from "vitest";
import { validate, type Dir } from "./client";

const vectors = JSON.parse(readFileSync(new URL("../protocol_vectors.json", import.meta.url), "utf8"));

test.each(vectors.cases)("$name", (c: { dir: Dir; message: unknown; valid: boolean }) => {
  expect(validate(c.dir, c.message)).toBe(c.valid);
});

# Security advisory — repository sample code compromise (2026-01-16 to 2026-05-28)

## TL;DR

- **The published npm package `@superstateinc/api-key-request` (versions 0.1.0 through 0.1.4, latest published 2025-08-01) is NOT affected.** If you installed via `npm install @superstateinc/api-key-request` and use the package by importing `superstateApiKeyRequest` in your own code, no action is needed.
- **The GitHub repository's sample file `src/example.ts` contained malicious code from 2026-01-16 to 2026-05-28.** If you cloned this repository AND ran `pnpm start` (or otherwise executed `src/example.ts`) during that window, see "Recommended action" below.

## What happened

On 2026-01-16, the file `src/example.ts` was modified by malicious code as part of a broader npm supply-chain attack on a developer machine. The change was hidden behind whitespace padding in commit `e180dd8` and appeared as a single-line diff. The malicious code was not detected until 2026-05-28, when it was identified as part of an incident response involving an unrelated repository.

## What was affected

- This repository (`superstateinc/request-with-api-key`), `src/example.ts` only.
- Anyone who cloned this repository between 2026-01-16 and 2026-05-28 AND ran `pnpm start` (which executes `tsx src/example.ts`) on their local machine during that window may have executed the malicious code.

## What was NOT affected

- The published npm package `@superstateinc/api-key-request`. The package was last published on 2025-08-01, before the malicious code was introduced. The package's compiled `example.js` predates the malicious change.
- Other Superstate APIs, services, or customer data.
- Anyone who only installed the package via `npm install` without cloning the repository.

## Recommended action for affected cloners

If you cloned this repository between 2026-01-16 and 2026-05-28 AND ran `pnpm start` (or otherwise executed `src/example.ts`) on your local machine:

1. Rotate any credentials present in your local `.env` (your Superstate API key and secret, plus any unrelated credentials).
2. Audit your machine for unfamiliar outbound network connections.
3. Pull the latest version of this repository to replace the malicious file with the safe version.
4. Reach out to security@superstate.co if you would like assistance or have questions.

## Technical detail

The injected loader was part of an npm-supply-chain campaign tracked by Google's Threat Intelligence Group as UNC5142. The loader attempted to read credentials from common local file locations and exfiltrate them to a remote endpoint. Indicators of compromise (file hashes, network endpoints, payload signatures) are available on request from security@superstate.co.

## Disclosure timeline

- 2026-01-16 — malicious code committed to `src/example.ts`
- 2026-05-28 — discovered during unrelated incident response; sample file restored to pre-incident state; this advisory published

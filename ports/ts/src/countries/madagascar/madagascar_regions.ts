import { tableResolver } from '../load';
import { data } from './data';

/** The `[D4-table]` letter → region lookup, from the generated data. */
const dealerCaptionOf = tableResolver<string | null>(data.resolvers['MadagascarRegions.dealerCaptionOf']);

export const MadagascarRegions = {
  /** For the temporary plate: the letter after `WW`. */
  temporaryCaptionOf(group: (key: string) => string): string | null {
    const series = group('series');
    return series.length === 3 && series.startsWith('WW') ? dealerCaptionOf(() => series[2]) : null;
  },
};

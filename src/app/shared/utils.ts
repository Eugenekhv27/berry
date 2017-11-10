
export function appParseNumber(v: string|number): number {
  return isNaN(parseFloat(String(v))) ? 0 : parseFloat(String(v));
}

export function appParseDate(s: string) {
  const ps = s
    .split('.')
    .map(v => parseInt(v, 10));
  return new Date(ps[2], ps[1] - 1, ps[0]);
}

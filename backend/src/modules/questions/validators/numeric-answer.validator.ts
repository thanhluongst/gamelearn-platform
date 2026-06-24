export class NumericAnswerValidator {
  /**
   * Parses various numeric formats:
   * - Integers: "5", "-3"
   * - Decimals: "3.14", "3,14"
   * - Fractions: "1/2", "3/4", "2/4"
   * Returns null if cannot parse.
   */
  static parse(value: string): number | null {
    if (!value) return null;
    const v = value.trim().replace(/\s/g, '');

    // Fraction: "1/2"
    if (v.includes('/')) {
      const parts = v.split('/');
      if (parts.length === 2) {
        const num = parseFloat(parts[0]);
        const den = parseFloat(parts[1]);
        if (!isNaN(num) && !isNaN(den) && den !== 0) {
          return num / den;
        }
      }
      return null;
    }

    // Decimal with comma: "3,14"
    const normalized = v.replace(',', '.');
    const num = parseFloat(normalized);
    return isNaN(num) ? null : num;
  }

  static areEqual(a: string, b: string, tolerance = 0.001): boolean {
    const numA = this.parse(a);
    const numB = this.parse(b);
    if (numA === null || numB === null) return false;
    return Math.abs(numA - numB) <= tolerance;
  }

  static normalize(value: string): string | null {
    const num = this.parse(value);
    if (num === null) return null;
    // Return without trailing zeros
    return num % 1 === 0 ? String(Math.round(num)) : String(num);
  }
}

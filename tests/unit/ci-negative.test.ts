import { expect, it } from 'vitest';

// W11-08: намеренно падающий тест для доказательства красного CI.
// Этот файл не должен попасть в develop/main.
it('deliberately fails to prove CI blocks broken code', () => {
  expect(1).toBe(2);
});

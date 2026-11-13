import { describe, expect, it } from 'vitest';

import { APP_NAME, APP_TITLE, getAppTitle } from '../../src/lib/app-info';

describe('app-info', () => {
  it('exposes the stable product name and page title', () => {
    expect(APP_NAME).toBe('RL');
    expect(getAppTitle()).toBe(APP_TITLE);
    expect(APP_TITLE).toContain('русский язык');
  });
});

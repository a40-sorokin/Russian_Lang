import { expect, test } from '@playwright/test';

test('главная страница показывает каркас RL', async ({ page }) => {
  await page.goto('/');

  await expect(page).toHaveTitle('RL — русский язык');
  await expect(page.getByRole('heading', { level: 1, name: 'RL — русский язык' })).toBeVisible();
  await expect(page.getByRole('heading', { level: 2, name: 'Диктанты' })).toBeVisible();
  await expect(page.getByRole('heading', { level: 2, name: 'Дерево правил' })).toBeVisible();
  await expect(page.getByText('В разработке')).toHaveCount(2);
  await expect(
    page.getByText('Технический каркас приложения. Учебные функции пока недоступны.'),
  ).toBeVisible();
});

test('liveness endpoint отвечает без кэширования', async ({ request }) => {
  const response = await request.get('/api/health');

  expect(response.status()).toBe(200);
  expect(response.headers()['cache-control']).toBe('no-store');
  await expect(response.json()).resolves.toEqual({ status: 'ok', service: 'rl' });
});

test('на ширине 320 px нет горизонтальной прокрутки', async ({ page }) => {
  await page.setViewportSize({ width: 320, height: 800 });
  await page.goto('/');

  const metrics = await page.evaluate(() => ({
    scrollWidth: document.documentElement.scrollWidth,
    clientWidth: document.documentElement.clientWidth,
  }));

  expect(metrics.scrollWidth).toBeLessThanOrEqual(metrics.clientWidth);
});

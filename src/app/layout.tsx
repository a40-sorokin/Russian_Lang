import type { Metadata } from 'next';

import { APP_DESCRIPTION, APP_TITLE } from '@/lib/app-info';

import './globals.css';

export const metadata: Metadata = {
  title: APP_TITLE,
  description: APP_DESCRIPTION,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ru">
      <body>{children}</body>
    </html>
  );
}

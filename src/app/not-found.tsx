import Link from 'next/link';

export default function NotFound() {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col justify-center px-4 py-12">
      <h1 className="text-3xl font-bold text-slate-900">Страница не найдена</h1>
      <p className="mt-3 text-slate-600">Запрошенный раздел пока не существует.</p>
      <Link className="mt-6 text-blue-700 underline" href="/">
        Вернуться на главную
      </Link>
    </main>
  );
}

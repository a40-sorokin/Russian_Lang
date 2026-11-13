const sections = [
  {
    title: 'Диктанты',
    description:
      'Онлайн-диктанты с пропущенными буквами и знаками препинания, связанные с правилами из дерева.',
  },
  {
    title: 'Дерево правил',
    description:
      'Наглядная структура правил русского языка и отслеживание прогресса по каждому узлу.',
  },
];

export default function Home() {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-5xl flex-col justify-center px-4 py-12 sm:px-6 lg:px-8">
      <header className="max-w-3xl">
        <p className="text-sm font-semibold tracking-wide text-blue-700 uppercase">RL</p>
        <h1 className="mt-3 text-3xl font-bold tracking-tight text-slate-900 sm:text-4xl">
          RL — русский язык
        </h1>
        <p className="mt-4 text-base leading-7 text-slate-700 sm:text-lg">
          Сервис для тренировки орфографии и пунктуации и подготовки к ЕГЭ.
        </p>
      </header>

      <div className="mt-10 grid gap-4 sm:grid-cols-2">
        {sections.map((section) => (
          <section
            key={section.title}
            className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm"
          >
            <div className="flex items-start justify-between gap-3">
              <h2 className="text-xl font-semibold text-slate-900">{section.title}</h2>
              <span className="shrink-0 rounded-full bg-amber-100 px-3 py-1 text-xs font-semibold text-amber-900">
                В разработке
              </span>
            </div>
            <p className="mt-3 text-sm leading-6 text-slate-600">{section.description}</p>
          </section>
        ))}
      </div>

      <p className="mt-10 border-t border-slate-200 pt-5 text-sm text-slate-500">
        Технический каркас приложения. Учебные функции пока недоступны.
      </p>
    </main>
  );
}

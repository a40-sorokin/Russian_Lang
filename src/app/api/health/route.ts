export function GET() {
  return Response.json(
    { status: 'ok', service: 'rl' },
    {
      status: 200,
      headers: {
        'Cache-Control': 'no-store',
      },
    },
  );
}

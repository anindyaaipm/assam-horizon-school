// Vercel serverless function to expose Supabase env vars safely at runtime
// Expected env vars configured in Vercel: SUPABASE_URL, SUPABASE_ANON_KEY

export default function handler(req, res) {
  // Allow only GET
  if (req.method !== 'GET') {
    res.setHeader('Allow', 'GET');
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  // Basic no-cache to ensure fresh values
  res.setHeader('Cache-Control', 'no-store');

  const url = process.env.SUPABASE_URL || '';
  const anonKey = process.env.SUPABASE_ANON_KEY || '';

  if (!url || !anonKey) {
    return res.status(500).json({ error: 'Missing SUPABASE_URL or SUPABASE_ANON_KEY' });
  }

  return res.status(200).json({ url, anonKey });
}





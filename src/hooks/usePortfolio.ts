import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import type { PortfolioData } from '@/types';

const emptyData: PortfolioData = { profile: null, experience: [], projects: [], skills: [], education: [], achievements: [], certifications: [], warStories: [], learning: [], socialLinks: [] };

export function usePortfolio(includeDrafts = false) {
  const [data, setData] = useState<PortfolioData>(emptyData);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    const projectsQuery = supabase.from('portfolio_projects').select('*').order('sort_order', { ascending: true });
    const experienceQuery = supabase.from('portfolio_experience').select('*').order('sort_order', { ascending: true });
    const [profile, experience, projects, skills, education, achievements, certifications, warStories, learning, socialLinks] = await Promise.all([
      supabase.from('portfolio_profile').select('*').order('updated_at', { ascending: false }).limit(1).maybeSingle(),
      includeDrafts ? experienceQuery : experienceQuery.or('published.is.null,published.eq.true'),
      includeDrafts ? projectsQuery : projectsQuery.eq('published', true).eq('draft', false),
      supabase.from('portfolio_skills').select('*').eq('published', true).order('sort_order', { ascending: true }),
      supabase.from('portfolio_education').select('*').eq('published', true).order('sort_order', { ascending: true }),
      supabase.from('portfolio_achievements').select('*').order('sort_order', { ascending: true }),
      supabase.from('portfolio_certifications').select('*').eq('published', true).order('sort_order', { ascending: true }),
      supabase.from('portfolio_war_stories').select('*').eq('published', true).order('sort_order', { ascending: true }),
      supabase.from('portfolio_learning').select('*').eq('published', true).order('sort_order', { ascending: true }),
      supabase.from('portfolio_social_links').select('*').eq('published', true).order('sort_order', { ascending: true }),
    ]);
    const failed = [profile, experience, projects, skills, education, achievements, certifications, warStories, learning, socialLinks].find((result) => result.error);
    if (failed?.error) setError(failed.error.message);
    else setData({ profile: profile.data, experience: experience.data ?? [], projects: projects.data ?? [], skills: skills.data ?? [], education: education.data ?? [], achievements: achievements.data ?? [], certifications: certifications.data ?? [], warStories: warStories.data ?? [], learning: learning.data ?? [], socialLinks: socialLinks.data ?? [] });
    setLoading(false);
  }, [includeDrafts]);

  useEffect(() => { void load(); }, [load]);
  return { data, loading, error, reload: load };
}

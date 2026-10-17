export type Profile = {
  id: string;
  full_name: string;
  headline: string;
  location: string | null;
  bio: string;
  email: string | null;
  phone?: string | null;
  linkedin_url: string | null;
  github_url?: string | null;
  website_url: string | null;
  resume_url?: string | null;
  profile_image_url?: string | null;
  availability: string | null;
  updated_at: string;
};

export type Experience = {
  id: string;
  company: string;
  role: string;
  start_date: string;
  end_date: string | null;
  location: string | null;
  description: string;
  technologies?: string[];
  published?: boolean;
  sort_order: number;
};

export type Project = {
  id: string;
  title: string;
  slug?: string | null;
  summary: string;
  category: string | null;
  problem?: string | null;
  architecture?: string | null;
  responsibilities?: string | null;
  outcomes?: string | null;
  technologies: string[];
  tags?: string[];
  screenshots?: string[];
  project_url: string | null;
  github_url?: string | null;
  demo_url?: string | null;
  featured: boolean;
  published: boolean;
  draft?: boolean;
  sort_order: number;
};

export type Skill = { id: string; name: string; category: string; proficiency: string | null; icon?: string | null; published?: boolean; sort_order: number };
export type Education = { id: string; institution: string; program: string; dates: string | null; detail: string | null; source_url?: string | null; published?: boolean; sort_order: number };
export type Achievement = { id: string; title: string; description: string; category: string | null; date: string | null; sort_order: number };
export type Certification = { id: string; name: string; issuer: string; date: string | null; issued_date?: string | null; expiry_date?: string | null; credential_id?: string | null; credential_url: string | null; badge_url?: string | null; description: string; published?: boolean; sort_order: number };
export type WarStory = { id: string; title: string; environment: string; symptoms: string; investigation: string; root_cause: string; resolution: string; impact: string; lessons_learned: string; severity: string; tags: string[]; published: boolean; sort_order: number };
export type LearningEntry = { id: string; title: string; source: string; learned_on: string | null; notes: string; tags: string[]; published: boolean; sort_order: number };
export type SocialLink = { id: string; label: string; url: string; icon: string | null; published: boolean; sort_order: number };

export type PortfolioData = {
  profile: Profile | null;
  experience: Experience[];
  projects: Project[];
  skills: Skill[];
  education: Education[];
  achievements: Achievement[];
  certifications: Certification[];
  warStories: WarStory[];
  learning: LearningEntry[];
  socialLinks: SocialLink[];
};

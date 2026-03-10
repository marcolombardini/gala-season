import { useForm, Head } from '@inertiajs/react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Switch } from '@/components/ui/switch'
import { Badge } from '@/components/ui/badge'
import type { FormEvent } from 'react'
import type { SettingsUser } from '@/types'

const CAUSES = [
  'Education', 'Health', 'Arts & Culture', 'Environment', 'Animal Welfare',
  'Social Justice', 'Hunger & Poverty', 'Veterans', 'Youth Development',
  'Mental Health', 'Housing', 'Disaster Relief', 'Community Development',
  'Science & Research', "Women's Empowerment",
]

const INDUSTRIES = [
  'Nonprofit', 'Healthcare', 'Technology', 'Finance',
  'Real Estate', 'Entertainment', 'Legal', 'Energy',
]

export default function Settings({ user }: { user: SettingsUser }) {
  const { data, setData, patch, processing, errors, transform } = useForm({
    first_name: user.first_name,
    last_name: user.last_name,
    email: user.email,
    username: user.username,
    bio: user.bio ?? '',
    birthdate: user.birthdate ?? '',
    sex: user.sex ?? '',
    city: user.city ?? '',
    state: user.state ?? '',
    social_x: user.social_x ?? '',
    social_linkedin: user.social_linkedin ?? '',
    social_instagram: user.social_instagram ?? '',
    social_facebook: user.social_facebook ?? '',
    interested_causes: user.interested_causes ?? [],
    interested_industries: user.interested_industries ?? [],
    visibility: user.visibility,
    visibility_full_name: user.visibility_full_name,
    visibility_email: user.visibility_email,
    password: '',
    password_confirmation: '',
  })

  function submit(e: FormEvent) {
    e.preventDefault()
    transform(formData => ({ user: formData }))
    patch('/settings')
  }

  function toggleArrayItem(field: 'interested_causes' | 'interested_industries', item: string) {
    const current = data[field]
    if (current.includes(item)) {
      setData(field, current.filter(i => i !== item))
    } else {
      setData(field, [...current, item])
    }
  }

  return (
    <>
      <Head title="Settings" />
      <div className="mx-auto max-w-3xl px-4 py-10 sm:px-6 lg:px-8">
        <h1 className="mb-8 text-3xl font-bold tracking-tight">Settings</h1>

        <form onSubmit={submit} className="space-y-6">
          {/* Basic Info */}
          <Card>
            <CardHeader>
              <CardTitle>Basic Info</CardTitle>
              <CardDescription>Your name and account details</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="first_name">First name</Label>
                  <Input
                    id="first_name"
                    value={data.first_name}
                    onChange={e => setData('first_name', e.target.value)}
                  />
                  {errors.first_name && (
                    <p className="text-sm text-destructive">{errors.first_name}</p>
                  )}
                </div>
                <div className="space-y-2">
                  <Label htmlFor="last_name">Last name</Label>
                  <Input
                    id="last_name"
                    value={data.last_name}
                    onChange={e => setData('last_name', e.target.value)}
                  />
                  {errors.last_name && (
                    <p className="text-sm text-destructive">{errors.last_name}</p>
                  )}
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  value={data.email}
                  onChange={e => setData('email', e.target.value)}
                />
                {errors.email && (
                  <p className="text-sm text-destructive">{errors.email}</p>
                )}
              </div>

              <div className="space-y-2">
                <Label htmlFor="username">Username</Label>
                <Input
                  id="username"
                  value={data.username}
                  onChange={e => setData('username', e.target.value)}
                />
                {errors.username && (
                  <p className="text-sm text-destructive">{errors.username}</p>
                )}
              </div>
            </CardContent>
          </Card>

          {/* Profile */}
          <Card>
            <CardHeader>
              <CardTitle>Profile</CardTitle>
              <CardDescription>Tell others about yourself</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="bio">Bio</Label>
                <Textarea
                  id="bio"
                  value={data.bio}
                  onChange={e => setData('bio', e.target.value)}
                  rows={3}
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="birthdate">Birthdate</Label>
                  <Input
                    id="birthdate"
                    type="date"
                    value={data.birthdate}
                    onChange={e => setData('birthdate', e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="sex">Sex</Label>
                  <select
                    id="sex"
                    value={data.sex}
                    onChange={e => setData('sex', e.target.value)}
                    className="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
                  >
                    <option value="">Prefer not to say</option>
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="city">City</Label>
                  <Input
                    id="city"
                    value={data.city}
                    onChange={e => setData('city', e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="state">State</Label>
                  <Input
                    id="state"
                    value={data.state}
                    onChange={e => setData('state', e.target.value)}
                  />
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Social Links */}
          <Card>
            <CardHeader>
              <CardTitle>Social Links</CardTitle>
              <CardDescription>Your social media profiles</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="social_x">X (Twitter)</Label>
                <Input
                  id="social_x"
                  value={data.social_x}
                  onChange={e => setData('social_x', e.target.value)}
                  placeholder="@handle or URL"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="social_linkedin">LinkedIn</Label>
                <Input
                  id="social_linkedin"
                  value={data.social_linkedin}
                  onChange={e => setData('social_linkedin', e.target.value)}
                  placeholder="username or URL"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="social_instagram">Instagram</Label>
                <Input
                  id="social_instagram"
                  value={data.social_instagram}
                  onChange={e => setData('social_instagram', e.target.value)}
                  placeholder="@handle or URL"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="social_facebook">Facebook</Label>
                <Input
                  id="social_facebook"
                  value={data.social_facebook}
                  onChange={e => setData('social_facebook', e.target.value)}
                  placeholder="username or URL"
                />
              </div>
            </CardContent>
          </Card>

          {/* Interests */}
          <Card>
            <CardHeader>
              <CardTitle>Interests</CardTitle>
              <CardDescription>Select causes and industries you care about</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="space-y-3">
                <Label>Causes</Label>
                <div className="flex flex-wrap gap-2">
                  {CAUSES.map(cause => (
                    <Badge
                      key={cause}
                      variant={data.interested_causes.includes(cause) ? 'default' : 'outline'}
                      className="cursor-pointer"
                      onClick={() => toggleArrayItem('interested_causes', cause)}
                    >
                      {cause}
                    </Badge>
                  ))}
                </div>
              </div>

              <div className="space-y-3">
                <Label>Industries</Label>
                <div className="flex flex-wrap gap-2">
                  {INDUSTRIES.map(industry => (
                    <Badge
                      key={industry}
                      variant={data.interested_industries.includes(industry) ? 'default' : 'outline'}
                      className="cursor-pointer"
                      onClick={() => toggleArrayItem('interested_industries', industry)}
                    >
                      {industry}
                    </Badge>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Privacy */}
          <Card>
            <CardHeader>
              <CardTitle>Privacy</CardTitle>
              <CardDescription>Control what others can see</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <Label htmlFor="visibility">Show my profile publicly</Label>
                <Switch
                  id="visibility"
                  checked={data.visibility}
                  onCheckedChange={checked => setData('visibility', checked)}
                />
              </div>
              <div className="flex items-center justify-between">
                <Label htmlFor="visibility_full_name">Show my full name</Label>
                <Switch
                  id="visibility_full_name"
                  checked={data.visibility_full_name}
                  onCheckedChange={checked => setData('visibility_full_name', checked)}
                />
              </div>
              <div className="flex items-center justify-between">
                <Label htmlFor="visibility_email">Show my email</Label>
                <Switch
                  id="visibility_email"
                  checked={data.visibility_email}
                  onCheckedChange={checked => setData('visibility_email', checked)}
                />
              </div>
            </CardContent>
          </Card>

          {/* Change Password */}
          <Card>
            <CardHeader>
              <CardTitle>Change Password</CardTitle>
              <CardDescription>Leave blank to keep your current password</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="password">New password</Label>
                <Input
                  id="password"
                  type="password"
                  value={data.password}
                  onChange={e => setData('password', e.target.value)}
                  autoComplete="new-password"
                />
                {errors.password && (
                  <p className="text-sm text-destructive">{errors.password}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="password_confirmation">Confirm new password</Label>
                <Input
                  id="password_confirmation"
                  type="password"
                  value={data.password_confirmation}
                  onChange={e => setData('password_confirmation', e.target.value)}
                  autoComplete="new-password"
                />
                {errors.password_confirmation && (
                  <p className="text-sm text-destructive">{errors.password_confirmation}</p>
                )}
              </div>
            </CardContent>
          </Card>

          <Button type="submit" disabled={processing} className="w-full">
            Save Changes
          </Button>
        </form>
      </div>
    </>
  )
}

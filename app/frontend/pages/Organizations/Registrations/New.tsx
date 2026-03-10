import { useForm, Link, Head } from '@inertiajs/react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import type { FormEvent, ReactNode } from 'react'

export default function OrganizationSignUp() {
  const { data, setData, post, processing, errors, transform } = useForm({
    name: '',
    email: '',
    password: '',
    password_confirmation: '',
  })

  function submit(e: FormEvent) {
    e.preventDefault()
    transform(formData => ({ organization: formData }))
    post('/organizations/sign_up')
  }

  return (
    <>
      <Head title="Organization Sign Up" />
      <div className="flex min-h-screen items-center justify-center bg-background">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <CardTitle className="text-2xl font-bold">Register your organization</CardTitle>
          <CardDescription>Start hosting events on Gala Season</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={submit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="name">Organization name</Label>
              <Input
                id="name"
                value={data.name}
                onChange={e => setData('name', e.target.value)}
                autoFocus
              />
              {errors.name && (
                <p className="text-sm text-destructive">{errors.name}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                value={data.email}
                onChange={e => setData('email', e.target.value)}
                autoComplete="email"
              />
              {errors.email && (
                <p className="text-sm text-destructive">{errors.email}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
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
              <Label htmlFor="password_confirmation">Confirm password</Label>
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

            <Button type="submit" className="w-full" disabled={processing}>
              Sign Up
            </Button>
          </form>
        </CardContent>
        <CardFooter className="flex flex-col gap-2 text-center text-sm">
          <p>
            Already have an account?{' '}
            <Link href="/organizations/sign_in" className="underline underline-offset-4 hover:text-primary">
              Sign in
            </Link>
          </p>
          <p>
            <Link href="/users/sign_up" className="underline underline-offset-4 hover:text-primary">
              Are you a user?
            </Link>
          </p>
        </CardFooter>
      </Card>
    </div>
    </>
  )
}

OrganizationSignUp.layout = (page: ReactNode) => page

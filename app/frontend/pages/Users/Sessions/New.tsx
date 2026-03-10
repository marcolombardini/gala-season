import { useForm, Link, usePage, Head } from '@inertiajs/react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import type { FormEvent, ReactNode } from 'react'

export default function UserSignIn() {
  const { errors } = usePage<{ errors: Record<string, string> }>().props
  const { data, setData, post, processing } = useForm({
    email: '',
    password: '',
  })

  function submit(e: FormEvent) {
    e.preventDefault()
    post('/users/sign_in')
  }

  return (
    <>
      <Head title="Sign In" />
      <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-background via-accent/10 to-primary/5">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <CardTitle className="text-2xl font-bold">Sign in to Gala Season</CardTitle>
          <CardDescription>Welcome back, philanthropist</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={submit} className="space-y-4">
            {errors.base && (
              <p className="text-sm text-destructive">{errors.base}</p>
            )}

            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                value={data.email}
                onChange={e => setData('email', e.target.value)}
                autoComplete="email"
                autoFocus
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                value={data.password}
                onChange={e => setData('password', e.target.value)}
                autoComplete="current-password"
              />
            </div>

            <Button type="submit" className="w-full" disabled={processing}>
              Sign In
            </Button>
          </form>
        </CardContent>
        <CardFooter className="flex flex-col gap-2 text-center text-sm">
          <p>
            Don't have an account?{' '}
            <Link href="/users/sign_up" className="underline underline-offset-4 hover:text-primary">
              Sign up
            </Link>
          </p>
          <p>
            <Link href="/organizations/sign_in" className="underline underline-offset-4 hover:text-primary">
              Are you an organization?
            </Link>
          </p>
        </CardFooter>
      </Card>
    </div>
    </>
  )
}

UserSignIn.layout = (page: ReactNode) => page

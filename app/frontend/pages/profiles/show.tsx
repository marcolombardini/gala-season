import { Link } from '@inertiajs/react'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'
import type { DetailUser, EventListItem } from '@/types'

type FollowedOrganization = {
  id: string
  name: string
  slug: string
}

type ProfileProps = {
  user: DetailUser
  followed_organizations: FollowedOrganization[]
  attended_events: EventListItem[]
}

function formatDate(dateStr: string): string {
  const date = new Date(dateStr + 'T00:00:00')
  return date.toLocaleDateString('en-US', {
    weekday: 'short',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

function formatPrice(price: string | null): string {
  if (!price) return 'Price TBD'
  const num = parseFloat(price)
  if (num === 0) return 'Free'
  return `From $${num.toLocaleString('en-US', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`
}

function formatDressCode(code: string | null): string | null {
  if (!code) return null
  return code.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase())
}

function displayName(user: DetailUser): string | null {
  if (user.first_name && user.last_name) {
    return `${user.first_name} ${user.last_name}`
  }
  return null
}

function avatarInitials(user: DetailUser): string {
  if (user.first_name && user.last_name) {
    return `${user.first_name[0]}${user.last_name[0]}`
  }
  return '?'
}

export default function ProfileShow({
  user,
  followed_organizations,
  attended_events,
}: ProfileProps) {
  const name = displayName(user)

  return (
    <div className="mx-auto max-w-7xl px-4 py-8">
      <div className="mb-6">
        <Link
          href="/"
          className="text-sm text-muted-foreground hover:text-foreground"
        >
          &larr; Back to events
        </Link>
      </div>

      {/* Profile header */}
      <div className="mb-8 flex items-start gap-4">
        <div className="flex h-[64px] w-[64px] shrink-0 items-center justify-center rounded-full bg-muted text-xl font-semibold">
          {avatarInitials(user)}
        </div>
        <div>
          {name && (
            <h1 className="text-3xl font-bold tracking-tight">{name}</h1>
          )}
          <p className="text-muted-foreground">@{user.username}</p>
          <Badge className="mt-2">Philanthropist</Badge>
        </div>
      </div>

      {/* Bio & details */}
      {(user.bio || user.city || user.state || user.email) && (
        <div className="mb-8 space-y-2">
          {user.bio && (
            <p className="max-w-3xl text-muted-foreground">{user.bio}</p>
          )}
          <div className="flex flex-wrap items-center gap-4 text-sm text-muted-foreground">
            {(user.city || user.state) && (
              <span>{[user.city, user.state].filter(Boolean).join(', ')}</span>
            )}
            {user.email && (
              <a
                href={`mailto:${user.email}`}
                className="hover:text-foreground"
              >
                {user.email}
              </a>
            )}
          </div>
        </div>
      )}

      {/* Social links */}
      {(user.social_x ||
        user.social_linkedin ||
        user.social_instagram ||
        user.social_facebook) && (
        <div className="mb-8 flex flex-wrap gap-4 text-sm">
          {user.social_x && (
            <a
              href={user.social_x}
              target="_blank"
              rel="noopener noreferrer"
              className="text-muted-foreground hover:text-foreground"
            >
              X / Twitter
            </a>
          )}
          {user.social_linkedin && (
            <a
              href={user.social_linkedin}
              target="_blank"
              rel="noopener noreferrer"
              className="text-muted-foreground hover:text-foreground"
            >
              LinkedIn
            </a>
          )}
          {user.social_instagram && (
            <a
              href={user.social_instagram}
              target="_blank"
              rel="noopener noreferrer"
              className="text-muted-foreground hover:text-foreground"
            >
              Instagram
            </a>
          )}
          {user.social_facebook && (
            <a
              href={user.social_facebook}
              target="_blank"
              rel="noopener noreferrer"
              className="text-muted-foreground hover:text-foreground"
            >
              Facebook
            </a>
          )}
        </div>
      )}

      <Separator className="mb-8" />

      {/* Causes & Networks */}
      <div className="mb-8 grid grid-cols-1 gap-8 md:grid-cols-2">
        {user.interested_causes.length > 0 && (
          <div>
            <h2 className="mb-3 text-lg font-semibold">My Causes</h2>
            <div className="flex flex-wrap gap-2">
              {user.interested_causes.map((cause) => (
                <Badge key={cause} variant="secondary">
                  {cause}
                </Badge>
              ))}
            </div>
          </div>
        )}

        {user.interested_industries.length > 0 && (
          <div>
            <h2 className="mb-3 text-lg font-semibold">My Networks</h2>
            <div className="flex flex-wrap gap-2">
              {user.interested_industries.map((industry) => (
                <Badge key={industry} variant="secondary">
                  {industry}
                </Badge>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Following Organizations */}
      {followed_organizations.length > 0 && (
        <>
          <Separator className="mb-8" />
          <div className="mb-8">
            <h2 className="mb-4 text-2xl font-bold">
              Following Organizations
            </h2>
            <div className="flex flex-wrap gap-3">
              {followed_organizations.map((org) => (
                <Link key={org.id} href={`/o/${org.slug}`}>
                  <Badge
                    variant="outline"
                    className="cursor-pointer px-4 py-2 text-sm hover:bg-accent"
                  >
                    {org.name}
                  </Badge>
                </Link>
              ))}
            </div>
          </div>
        </>
      )}

      {/* Attended Events */}
      {attended_events.length > 0 && (
        <>
          <Separator className="mb-8" />
          <div>
            <h2 className="mb-6 text-2xl font-bold">Attending Events</h2>
            <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
              {attended_events.map((event) => (
                <Link key={event.id} href={`/events/${event.id}`}>
                  <Card className="h-full transition-colors hover:border-foreground/20">
                    <CardHeader>
                      <CardTitle className="text-lg">{event.title}</CardTitle>
                      <p className="text-sm text-muted-foreground">
                        {formatDate(event.date)}
                      </p>
                    </CardHeader>
                    <CardContent>
                      <div className="space-y-1 text-sm text-muted-foreground">
                        {event.venue_name && <p>{event.venue_name}</p>}
                        {(event.city || event.state) && (
                          <p>
                            {[event.city, event.state]
                              .filter(Boolean)
                              .join(', ')}
                          </p>
                        )}
                        <p className="font-semibold text-foreground">
                          {formatPrice(event.starting_ticket_price)}
                        </p>
                        {event.dress_code && (
                          <Badge variant="outline" className="mt-2">
                            {formatDressCode(event.dress_code)}
                          </Badge>
                        )}
                      </div>
                    </CardContent>
                  </Card>
                </Link>
              ))}
            </div>
          </div>
        </>
      )}
    </div>
  )
}

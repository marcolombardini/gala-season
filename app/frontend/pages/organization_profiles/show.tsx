import { Link } from '@inertiajs/react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import type { DetailOrganization, EventListItem } from '@/types'

type OrganizationProfileProps = {
  organization: DetailOrganization
  events: EventListItem[]
  follower_count: number
  is_following: boolean
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


export default function OrganizationProfileShow({
  organization,
  events,
  follower_count,
}: OrganizationProfileProps) {
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

      {/* Org header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold tracking-tight">
          {organization.name}
        </h1>

        {organization.description && (
          <p className="mt-3 max-w-3xl text-muted-foreground">
            {organization.description}
          </p>
        )}

        {/* Contact info */}
        <div className="mt-4 flex flex-wrap items-center gap-4 text-sm text-muted-foreground">
          {organization.website && (
            <a
              href={organization.website}
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-foreground"
            >
              {organization.website.replace(/^https?:\/\//, '')}
            </a>
          )}
          {organization.email && (
            <a
              href={`mailto:${organization.email}`}
              className="hover:text-foreground"
            >
              {organization.email}
            </a>
          )}
          {organization.phone && (
            <a
              href={`tel:${organization.phone}`}
              className="hover:text-foreground"
            >
              {organization.phone}
            </a>
          )}
        </div>

        {/* Actions row */}
        <div className="mt-4 flex flex-wrap items-center gap-3">
          {organization.donation_url && (
            <Button asChild>
              <a
                href={organization.donation_url}
                target="_blank"
                rel="noopener noreferrer"
              >
                Donate
              </a>
            </Button>
          )}

          {/* Placeholder — wired in Phase 13 */}
          <Button variant="outline" disabled>
            Follow
          </Button>

          <span className="text-sm text-muted-foreground">
            <span className="font-semibold text-foreground">
              {follower_count}
            </span>{' '}
            {follower_count === 1 ? 'follower' : 'followers'}
          </span>
        </div>
      </div>

      <Separator className="mb-8" />

      {/* Causes & Industries */}
      <div className="mb-8 grid grid-cols-1 gap-8 md:grid-cols-2">
        {organization.causes.length > 0 && (
          <div>
            <h2 className="mb-3 text-lg font-semibold">Causes We Support</h2>
            <div className="flex flex-wrap gap-2">
              {organization.causes.map((cause) => (
                <Badge
                  key={cause}
                  variant={
                    cause === organization.primary_cause
                      ? 'default'
                      : 'secondary'
                  }
                >
                  {cause}
                </Badge>
              ))}
            </div>
          </div>
        )}

        {organization.industries.length > 0 && (
          <div>
            <h2 className="mb-3 text-lg font-semibold">
              Industries &amp; Networks
            </h2>
            <div className="flex flex-wrap gap-2">
              {organization.industries.map((industry) => (
                <Badge key={industry} variant="secondary">
                  {industry}
                </Badge>
              ))}
            </div>
          </div>
        )}
      </div>

      <Separator className="mb-8" />

      {/* Events section */}
      <div>
        <h2 className="mb-6 text-2xl font-bold">
          Events by {organization.name}
        </h2>

        {events.length === 0 ? (
          <p className="text-muted-foreground">No upcoming events.</p>
        ) : (
          <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3 stagger-grid">
            {events.map((event) => (
              <Link key={event.id} href={`/events/${event.id}`} className="animate-fade-up">
                <Card className="h-full transition-all duration-200 hover:shadow-[0_4px_12px_rgba(0,0,0,0.08),0_2px_4px_rgba(0,0,0,0.04)] hover:-translate-y-0.5 pt-0 overflow-hidden">
                  <div className="h-32 bg-gradient-to-br from-primary/15 to-primary/5" />
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
        )}
      </div>
    </div>
  )
}

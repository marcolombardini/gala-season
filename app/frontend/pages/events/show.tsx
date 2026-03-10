import { Link } from '@inertiajs/react'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import type { Event, DetailOrganization } from '@/types'

type EventShowProps = {
  event: Event
  organization: DetailOrganization
  attendee_count: number
  is_attending: boolean
}

function formatDate(dateStr: string): string {
  const date = new Date(dateStr + 'T00:00:00')
  return date.toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

function formatTime(timeStr: string | null): string | null {
  if (!timeStr) return null
  const date = new Date(timeStr)
  return date.toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    timeZone: 'UTC',
  })
}

function formatPrice(price: string | null): string {
  if (!price) return 'Price TBD'
  const num = parseFloat(price)
  if (num === 0) return 'Free'
  return `$${num.toLocaleString('en-US', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`
}

function formatDressCode(code: string | null): string | null {
  if (!code) return null
  return code.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase())
}

export default function EventShow({
  event,
  organization,
  attendee_count,
}: EventShowProps) {
  const dressCode = formatDressCode(event.dress_code)
  const startTime = formatTime(event.start_time)
  const endTime = formatTime(event.end_time)
  const timeRange =
    startTime && endTime
      ? `${startTime} – ${endTime}`
      : startTime || endTime || null

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

      <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
        {/* Left column — main content */}
        <div className="lg:col-span-2">
          <div className="mb-6 h-48 rounded-lg bg-gradient-to-r from-muted to-muted/50" />

          <h1 className="text-3xl font-bold tracking-tight">{event.title}</h1>

          <p className="mt-1 text-muted-foreground">
            Hosted by{' '}
            <Link
              href={`/o/${organization.slug}`}
              className="font-medium text-foreground underline-offset-4 hover:underline"
            >
              {organization.name}
            </Link>
          </p>

          {event.description && (
            <p className="mt-6 whitespace-pre-wrap text-muted-foreground">
              {event.description}
            </p>
          )}

          {event.hashtags && event.hashtags.length > 0 && (
            <div className="mt-6 flex flex-wrap gap-2">
              {event.hashtags.map((tag) => (
                <Badge key={tag} variant="secondary">
                  #{tag}
                </Badge>
              ))}
            </div>
          )}
        </div>

        {/* Right column — sidebar */}
        <div className="lg:col-span-1">
          <Card>
            <CardContent className="space-y-4 p-6">
              {/* Date & Time */}
              <div>
                <p className="text-sm font-medium text-muted-foreground">
                  Date
                </p>
                <p className="font-semibold">{formatDate(event.date)}</p>
                {timeRange && (
                  <p className="text-sm text-muted-foreground">{timeRange}</p>
                )}
              </div>

              <Separator />

              {/* Venue & Address */}
              {event.venue_name && (
                <div>
                  <p className="text-sm font-medium text-muted-foreground">
                    Venue
                  </p>
                  <p className="font-semibold">{event.venue_name}</p>
                  {event.street_address && (
                    <p className="text-sm text-muted-foreground">
                      {event.street_address}
                    </p>
                  )}
                  {(event.city || event.state || event.zip) && (
                    <p className="text-sm text-muted-foreground">
                      {[event.city, event.state].filter(Boolean).join(', ')}
                      {event.zip ? ` ${event.zip}` : ''}
                    </p>
                  )}
                </div>
              )}

              {dressCode && (
                <>
                  <Separator />
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">
                      Dress Code
                    </p>
                    <Badge variant="outline">{dressCode}</Badge>
                  </div>
                </>
              )}

              <Separator />

              {/* Price & Tickets */}
              <div>
                <p className="text-sm font-medium text-muted-foreground">
                  Starting at
                </p>
                <p className="text-xl font-bold">
                  {formatPrice(event.starting_ticket_price)}
                </p>
              </div>

              {event.ticket_link && (
                <Button asChild className="w-full">
                  <a
                    href={event.ticket_link}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    Purchase Tickets
                  </a>
                </Button>
              )}

              {/* Auction / Gift badges */}
              {(event.auction_items || event.gift_items) && (
                <div className="flex flex-wrap gap-2">
                  {event.auction_items && (
                    <Badge variant="secondary">Auction Items</Badge>
                  )}
                  {event.gift_items && (
                    <Badge variant="secondary">Gift Items</Badge>
                  )}
                </div>
              )}

              <Separator />

              {/* Attendees */}
              <div>
                <p className="text-sm text-muted-foreground">
                  <span className="font-semibold text-foreground">
                    {attendee_count}
                  </span>{' '}
                  {attendee_count === 1 ? 'person' : 'people'} attending
                </p>
              </div>

              {/* Placeholder buttons — wired in Phase 13 */}
              <Button variant="outline" className="w-full" disabled>
                RSVP
              </Button>
              <Button variant="outline" className="w-full" disabled>
                Follow {organization.name}
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}

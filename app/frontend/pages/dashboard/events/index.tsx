import { Head, Link } from '@inertiajs/react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import type { DashboardEvent } from '@/types'

type DashboardEventsProps = {
  events: DashboardEvent[]
}

function formatDate(dateStr: string) {
  return new Date(dateStr + 'T00:00:00').toLocaleDateString('en-US', {
    month: 'long',
    day: 'numeric',
    year: 'numeric',
    timeZone: 'UTC',
  })
}

export default function DashboardEventsIndex({ events }: DashboardEventsProps) {
  return (
    <>
      <Head title="Your Events" />
      <div className="mx-auto max-w-5xl px-4 py-8">
        <div className="mb-6 flex items-center justify-between">
          <h1 className="text-2xl font-bold">Your Events</h1>
          <Button asChild>
            <Link href="/dashboard/events/new">Create Event</Link>
          </Button>
        </div>

        {events.length === 0 ? (
          <div className="rounded-lg border border-dashed p-12 text-center">
            <p className="text-muted-foreground">
              You haven&apos;t created any events yet.
            </p>
          </div>
        ) : (
          <div className="rounded-lg border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Title</TableHead>
                  <TableHead>Date</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Attendees</TableHead>
                  <TableHead />
                </TableRow>
              </TableHeader>
              <TableBody>
                {events.map((event) => (
                  <TableRow key={event.id}>
                    <TableCell className="font-medium">{event.title}</TableCell>
                    <TableCell>{formatDate(event.date)}</TableCell>
                    <TableCell>
                      <Badge
                        variant={
                          event.status === 'published' ? 'default' : 'secondary'
                        }
                      >
                        {event.status === 'published' ? 'Published' : 'Draft'}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-right">
                      {event.attendee_count}
                    </TableCell>
                    <TableCell className="text-right space-x-1">
                      {event.status === 'published' && (
                        <Button variant="ghost" size="sm" asChild>
                          <Link href={`/events/${event.id}`}>View</Link>
                        </Button>
                      )}
                      <Button variant="ghost" size="sm" asChild>
                        <Link href={`/dashboard/events/${event.id}/edit`}>
                          Edit
                        </Link>
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}
      </div>
    </>
  )
}

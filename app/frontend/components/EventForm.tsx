import { useForm, usePage } from '@inertiajs/react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Switch } from '@/components/ui/switch'
import type { Event } from '@/types'

type EventFormProps = {
  event?: Event
  dressCodes: string[]
}

const DRESS_CODE_LABELS: Record<string, string> = {
  black_tie: 'Black Tie',
  black_tie_optional: 'Black Tie Optional',
  cocktail_attire: 'Cocktail Attire',
  business_casual: 'Business Casual',
  formal: 'Formal',
  corporate: 'Corporate',
  corporate_festive: 'Corporate Festive',
  festive: 'Festive',
  festive_black_tie: 'Festive Black Tie',
}

function formatTimeForInput(timeStr: string | null): string {
  if (!timeStr) return ''
  const date = new Date(timeStr)
  const hours = date.getUTCHours().toString().padStart(2, '0')
  const minutes = date.getUTCMinutes().toString().padStart(2, '0')
  return `${hours}:${minutes}`
}

function formatDateForInput(dateStr: string | null | undefined): string {
  if (!dateStr) return ''
  return dateStr.split('T')[0]
}

export default function EventForm({ event, dressCodes }: EventFormProps) {
  const isEdit = !!event

  const { data, setData, post, patch, processing, errors, transform } =
    useForm({
      event: {
        title: event?.title ?? '',
        description: event?.description ?? '',
        date: formatDateForInput(event?.date),
        start_time: formatTimeForInput(event?.start_time ?? null),
        end_time: formatTimeForInput(event?.end_time ?? null),
        venue_name: event?.venue_name ?? '',
        street_address: event?.street_address ?? '',
        city: event?.city ?? '',
        state: event?.state ?? '',
        zip: event?.zip ?? '',
        dress_code: event?.dress_code ?? '',
        starting_ticket_price: event?.starting_ticket_price ?? '',
        ticket_link: event?.ticket_link ?? '',
        hashtags_input: (event?.hashtags ?? []).join(', '),
        countdown_timer: event?.countdown_timer ?? false,
        auction_items: event?.auction_items ?? false,
        gift_items: event?.gift_items ?? false,
        status: event?.status ?? 'draft',
      },
    })

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()

    transform((formData) => {
      const hashtags = formData.event.hashtags_input
        .split(',')
        .map((t: string) => t.trim())
        .filter(Boolean)

      const { hashtags_input: _, ...rest } = formData.event

      return {
        event: {
          ...rest,
          hashtags,
          dress_code: formData.event.dress_code || null,
          starting_ticket_price:
            formData.event.starting_ticket_price || null,
        },
      }
    })

    if (isEdit) {
      patch(`/dashboard/events/${event.id}`)
    } else {
      post('/dashboard/events')
    }
  }

  const pageErrors = usePage().props.errors as Record<string, string | string[]> | undefined

  function fieldError(field: string): string | undefined {
    // Check useForm errors (nested key) and page-level errors (flat key from redirect)
    const formKey = `event.${field}` as keyof typeof errors
    const formErr = errors[formKey] as string | undefined
    if (formErr) return formErr

    const pageErr = pageErrors?.[field]
    if (!pageErr) return undefined
    return Array.isArray(pageErr) ? pageErr[0] : pageErr
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>General Info</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="title">Title *</Label>
            <Input
              id="title"
              required
              value={data.event.title}
              onChange={(e) =>
                setData('event', { ...data.event, title: e.target.value })
              }
            />
            {fieldError('title') && (
              <p className="mt-1 text-sm text-destructive">
                {fieldError('title')}
              </p>
            )}
          </div>
          <div className="space-y-2">
            <Label htmlFor="description">Description</Label>
            <Textarea
              id="description"
              rows={4}
              value={data.event.description}
              onChange={(e) =>
                setData('event', { ...data.event, description: e.target.value })
              }
            />
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Date & Location</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-3 gap-4">
            <div className="space-y-2">
              <Label htmlFor="date">Date *</Label>
              <Input
                id="date"
                type="date"
                required
                value={data.event.date}
                onChange={(e) =>
                  setData('event', { ...data.event, date: e.target.value })
                }
              />
              {fieldError('date') && (
                <p className="mt-1 text-sm text-destructive">
                  {fieldError('date')}
                </p>
              )}
            </div>
            <div className="space-y-2">
              <Label htmlFor="start_time">Start Time</Label>
              <Input
                id="start_time"
                type="time"
                value={data.event.start_time}
                onChange={(e) =>
                  setData('event', {
                    ...data.event,
                    start_time: e.target.value,
                  })
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="end_time">End Time</Label>
              <Input
                id="end_time"
                type="time"
                value={data.event.end_time}
                onChange={(e) =>
                  setData('event', { ...data.event, end_time: e.target.value })
                }
              />
            </div>
          </div>
          <div className="space-y-2">
            <Label htmlFor="venue_name">Venue Name</Label>
            <Input
              id="venue_name"
              value={data.event.venue_name}
              onChange={(e) =>
                setData('event', { ...data.event, venue_name: e.target.value })
              }
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="street_address">Street Address</Label>
            <Input
              id="street_address"
              value={data.event.street_address}
              onChange={(e) =>
                setData('event', {
                  ...data.event,
                  street_address: e.target.value,
                })
              }
            />
          </div>
          <div className="grid grid-cols-3 gap-4">
            <div className="space-y-2">
              <Label htmlFor="city">City</Label>
              <Input
                id="city"
                value={data.event.city}
                onChange={(e) =>
                  setData('event', { ...data.event, city: e.target.value })
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="state">State</Label>
              <Input
                id="state"
                value={data.event.state}
                onChange={(e) =>
                  setData('event', { ...data.event, state: e.target.value })
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="zip">Zip</Label>
              <Input
                id="zip"
                value={data.event.zip}
                onChange={(e) =>
                  setData('event', { ...data.event, zip: e.target.value })
                }
              />
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Details</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="dress_code">Dress Code</Label>
              <Select
                value={data.event.dress_code}
                onValueChange={(value) =>
                  setData('event', {
                    ...data.event,
                    dress_code: value === 'none' ? '' : value,
                  })
                }
              >
                <SelectTrigger>
                  <SelectValue placeholder="Not specified" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="none">Not specified</SelectItem>
                  {dressCodes.map((code) => (
                    <SelectItem key={code} value={code}>
                      {DRESS_CODE_LABELS[code] || code}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label htmlFor="status">Status</Label>
              <Select
                value={data.event.status}
                onValueChange={(value) =>
                  setData('event', {
                    ...data.event,
                    status: value as 'draft' | 'published',
                  })
                }
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="draft">Draft</SelectItem>
                  <SelectItem value="published">Published</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="starting_ticket_price">
                Starting Ticket Price
              </Label>
              <Input
                id="starting_ticket_price"
                type="number"
                step="0.01"
                min="0"
                value={data.event.starting_ticket_price}
                onChange={(e) =>
                  setData('event', {
                    ...data.event,
                    starting_ticket_price: e.target.value,
                  })
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="ticket_link">Ticket Link</Label>
              <Input
                id="ticket_link"
                type="url"
                value={data.event.ticket_link}
                onChange={(e) =>
                  setData('event', {
                    ...data.event,
                    ticket_link: e.target.value,
                  })
                }
              />
            </div>
          </div>
          <div className="space-y-2">
            <Label htmlFor="hashtags_input">Hashtags (comma-separated)</Label>
            <Input
              id="hashtags_input"
              placeholder="e.g. charity, gala, fundraiser"
              value={data.event.hashtags_input}
              onChange={(e) =>
                setData('event', {
                  ...data.event,
                  hashtags_input: e.target.value,
                })
              }
            />
          </div>
          <div className="flex flex-wrap gap-8 pt-2">
            <div className="flex items-center gap-2">
              <Switch
                id="countdown_timer"
                checked={data.event.countdown_timer}
                onCheckedChange={(checked) =>
                  setData('event', { ...data.event, countdown_timer: checked })
                }
              />
              <Label htmlFor="countdown_timer">Countdown Timer</Label>
            </div>
            <div className="flex items-center gap-2">
              <Switch
                id="auction_items"
                checked={data.event.auction_items}
                onCheckedChange={(checked) =>
                  setData('event', { ...data.event, auction_items: checked })
                }
              />
              <Label htmlFor="auction_items">Auction Items</Label>
            </div>
            <div className="flex items-center gap-2">
              <Switch
                id="gift_items"
                checked={data.event.gift_items}
                onCheckedChange={(checked) =>
                  setData('event', { ...data.event, gift_items: checked })
                }
              />
              <Label htmlFor="gift_items">Gift Items</Label>
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="flex justify-end gap-3">
        <Button type="button" variant="outline" asChild>
          <a href="/dashboard/events">Cancel</a>
        </Button>
        <Button type="submit" disabled={processing}>
          {isEdit ? 'Update Event' : 'Create Event'}
        </Button>
      </div>
    </form>
  )
}

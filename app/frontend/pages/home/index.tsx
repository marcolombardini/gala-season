import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"

export default function Home() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <CardTitle className="text-4xl font-bold">Gala Season</CardTitle>
          <CardDescription className="text-lg">
            Browse, discover, and attend exclusive charitable gala events.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col items-center gap-4">
          <Badge variant="secondary">Coming Soon</Badge>
          <Button size="lg">Get Started</Button>
        </CardContent>
      </Card>
    </div>
  )
}

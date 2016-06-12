Durable WebSockets
==================

Example application implementing guaranteed delivery of messages from server application on [Ruby on Rails]) to client application in web browser using [RabbitMQ].

## How it works

_TODO: Write it verbosely_

It uses [WebStomp plugin for RabbitMQ] and various settings for all MQ stuff to make messages from classic Pub/Sub scheme not to lost in case of network lags and so on but to be delivered to every subscribed device.

See:

 - http://rubybunny.info/articles/durability.html
 - https://www.rabbitmq.com/stomp.html
 - http://www.rabbitmq.com/web-stomp.html
 - http://jmesnil.net/stomp-websocket/doc/

The meaningful places of code are:

 - [server/config/initializers/bunny_rabbitmq.rb at line 4](server/config/initializers/bunny_rabbitmq.rb#L4)
 - [server/config/initializers/rufus_scheduler.rb at line 10](server/config/initializers/rufus_scheduler.rb#L10)
 - [server/app/assets/javascripts/application.js at lines 55-61](server/app/assets/javascripts/application.js#L55-L61)


## How to test yourself

### 1. Launch it

#### Via Docker

You will need to have installed:

 - Recent [Docker]
 - Recent [Docker Compose]

Then just execute next command from this directory:

    docker-compose up --abort-on-container-exit

Access application on URL like this: http://your.external.ip.address:3000/


#### Manually

You will need to have installed:

 - Recent MRI Ruby version (recommended: 2.3)
 - Recent RabbitMQ version (3.6.2 or newer, even 3.5 doesn't work), and enable connects from non-localhost to it (See https://www.rabbitmq.com/access-control.html).
 - Recent Redis version (3.x probably)

Follow these simple steps:

 1. Install required gems by executing `bundle install` in `server` directory.

 2. Launch application with command like:

        cd server
        env RABBITMQ_URL=amqp://localhost CABLE_REDIS_URL=redis://localhost:6379/1 rails server --bind '0.0.0.0'

Access application on URL like this: http://your.external.ip.address:3000/

### 2. Test it

You will see messages arriving. Try next things:

 1. Close browser tab and reopen it after minute or so with `Ctrl+Shift+T` (`Cmd+Shift+T` on Mac)
 2. Unplug your LAN cord or disconnect from your Wi-Fi for minute or two and then reconnect (you MUST open application not on `localhost` but on your LAN of WLAN IP-address)

While tab is closed or you're disconnected, you can see on RabbitMQ management console at http://localhost:15672/#/queues that messages aren't lost but being accumulated in queue named `web-client-{your-tab-uuid}`.

After tab reopen or Wi-Fi reconnect you will see that _all_ messages were delivered to you and queue is empty.

Moreover, you will see that important messages were delivered first.


## License

> The MIT License (MIT)
> Copyright (c) 2016 Andrey Novikov
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[Ruby on Rails]: http://rubyonrails.org/
[RabbitMQ]: https://www.rabbitmq.com/
[WebStomp plugin for RabbitMQ]: https://www.rabbitmq.com/web-stomp.html
[Docker]: https://www.docker.com/
[Docker Compose]: https://docs.docker.com/compose/

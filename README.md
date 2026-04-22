# Clinic Medicine AI Recognition

AI-powered medicine recognition module for a clinic management WeChat mini-program.

## Overview

This project adds AI-driven medicine identification capabilities to a clinic management system, covering:
- New medicine creation (barcode scan / photo recognition)
- Medicine stock-in (barcode lookup)
- Medicine stock-out (barcode lookup + batch selection)
- Backend AI model configuration and switching

## Key Features

- Multi-model support: GPT-5.4 + MiniMax-M2.7
- Configurable AI provider/model/scene bindings via admin web UI
- Barcode scan and photo recognition with multiple candidate results
- Local database fallback for stock operations
- Full WeChat mini-program + SpringBoot backend implementation

## Architecture

- **Frontend**: WeChat Mini-Program (原生小程序)
- **Backend**: Java SpringBoot + MySQL
- **AI Layer**: Abstracted provider client with OpenAI and MiniMax adapters
- **Admin**: RuoYi-based web management console

## Documentation

See `MEDICINE_RECOGNITION_PLAN.md` for the full product design document (PRD-level).

## License
MIT

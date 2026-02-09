interface LogData {
  [key: string]: any;
}

class Logger {
  private static appName = 'VenueBookingApp';

  // ANSI color codes
  private static colors = {
    reset: '\x1b[0m',    // Reset to default
    green: '\x1b[32m',   // Green for INFO
    yellow: '\x1b[33m',  // Yellow for WARN  
    red: '\x1b[31m',     // Red for ERROR
    cyan: '\x1b[36m',    // Cyan for DEBUG (optional - you said keep same)
    // Other available colors:
    // blue: '\x1b[34m',
    // magenta: '\x1b[35m',
    // white: '\x1b[37m',
  };

  // Get color for log level
  private static getColorForLevel(level: string): string {
    switch (level) {
      case 'INFO': return this.colors.green;
      case 'WARN': return this.colors.yellow;
      case 'ERROR': return this.colors.red;
      case 'DEBUG': return this.colors.cyan; // or return '' to keep default
      default: return '';
    }
  }

  static info(message: string, component?: string, data?: LogData) {
    this.log('INFO', message, component, data);
  }

  static error(message: string, component?: string, data?: LogData, error?: any) {
    const errorData = { ...data };
    if (error) {
      errorData.error = error?.message || error;
      errorData.stack = error?.stack;
    }
    this.log('ERROR', message, component, errorData);
  }

  static debug(message: string, component?: string, data?: LogData) {
    this.log('DEBUG', message, component, data);
  }

  static warn(message: string, component?: string, data?: LogData) {
    this.log('WARN', message, component, data);
  }

  private static log(level: string, message: string, component?: string, data?: LogData) {
    const timestamp = new Date().toISOString();
    const componentStr = component ? `[${component}]` : '';

    // Get color for this level
    const levelColor = this.getColorForLevel(level);
    const resetColor = this.colors.reset;

    // Apply color only to the level tag
    const coloredLevel = `${levelColor}[${level}]${resetColor}`;

    // Convert data object to key=value pairs
    let structuredData = '';
    if (data && Object.keys(data).length > 0) {
      const keyValuePairs = Object.entries(data)
        .map(([key, value]) => `${key}=${JSON.stringify(value)}`)
        .join(', ');
      structuredData = `, ${keyValuePairs}`;
    }

    // Build the complete log message with colored level
    const logMessage = `[${timestamp}] [${this.appName}] ${coloredLevel} ${componentStr} ${message}${structuredData}`;

    switch (level) {
      case 'ERROR': console.error(logMessage); break;
      case 'WARN': console.warn(logMessage); break;
      case 'DEBUG': console.debug(logMessage); break;
      case 'INFO':
      default: console.log(logMessage); break;
    }
  }

  // Structured logging methods (with colors)
  static structured(level: string, message: string, component?: string, ...keyValuePairs: Array<{ key: string, value: any }>) {
    const timestamp = new Date().toISOString();
    const componentStr = component ? `[${component}]` : '';

    // Get color for this level
    const levelColor = this.getColorForLevel(level);
    const resetColor = this.colors.reset;
    const coloredLevel = `${levelColor}[${level}]${resetColor}`;

    // Format key=value pairs
    let structuredData = '';
    if (keyValuePairs.length > 0) {
      const pairs = keyValuePairs
        .map(pair => `${pair.key}=${JSON.stringify(pair.value)}`)
        .join(', ');
      structuredData = `, ${pairs}`;
    }

    const logMessage = `[${timestamp}] [${this.appName}] ${coloredLevel} ${componentStr} ${message}${structuredData}`;
    
    switch (level) {
      case 'ERROR': console.error(logMessage); break;
      case 'WARN': console.warn(logMessage); break;
      case 'DEBUG': console.debug(logMessage); break;
      case 'INFO':
      default: console.log(logMessage); break;
    }
  }

  // Convenience methods using the new structured format (with colors)
  static infoStructured(message: string, component?: string, ...keyValuePairs: Array<{ key: string, value: any }>) {
    this.structured('INFO', message, component, ...keyValuePairs);
  }

  static errorStructured(message: string, component?: string, error?: any, ...keyValuePairs: Array<{ key: string, value: any }>) {
    const allPairs = [...keyValuePairs];
    if (error) {
      allPairs.push({ key: 'error', value: error?.message || error });
    }
    this.structured('ERROR', message, component, ...allPairs);
  }

  static warnStructured(message: string, component?: string, ...keyValuePairs: Array<{ key: string, value: any }>) {
    this.structured('WARN', message, component, ...keyValuePairs);
  }

  static debugStructured(message: string, component?: string, ...keyValuePairs: Array<{ key: string, value: any }>) {
    this.structured('DEBUG', message, component, ...keyValuePairs);
  }

  // Optional: Method to disable colors (useful for production/file logging)
  static disableColors() {
    this.colors.green = '';
    this.colors.yellow = '';
    this.colors.red = '';
    this.colors.cyan = '';
    this.colors.reset = '';
  }

  // Optional: Method to test all colors
  static testColors() {
    console.log('🎨 Testing logger colors:');
    this.info('This is an info message', 'ColorTest');
    this.warn('This is a warning message', 'ColorTest');
    this.error('This is an error message', 'ColorTest');
    this.debug('This is a debug message', 'ColorTest');
  }
}

export { Logger };
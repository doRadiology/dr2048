import { Component, tracked, cellFor } from '@lifeart/gxt';

type Tile = {
  value: number;
  id: number;
  merged: boolean;
  className: string;
  previousPosition: { x: number; y: number } | null;
  x: number;
  y: number;
  isNew: boolean;
};


type GameState = {
  tiles: { value: number; x: number; y: number; id: number }[];
  sumScore: number;
  classicScore: number;
  maxSumScore: number;
  maxClassicScore: number;
  gameOver: boolean;
  tileId: number;
};

type Direction = 'up' | 'down' | 'left' | 'right';

export default class Game2048 extends Component {
  @tracked tiles: Tile[] = [];

  @tracked sumScore = 0;
  @tracked classicScore = 0;
  @tracked maxSumScore = 0;
  @tracked maxClassicScore = 0;
  @tracked isSumScoreMode = false;
  @tracked gameOver = false;

  @tracked isRowColMode = this.isMobile ? true : false;
  @tracked isFixedFourMode = false;

  @tracked isInfoDialogOpen = false;

  gridSize = 3;
  tileId = 0;

  touchStartRowIndex: number | null = null;
  touchStartColIndex: number | null = null;

  get isMobile() {
    const userAgent = navigator.userAgent || navigator.vendor || window.opera;
    // Check for Android, iOS, and Windows Phone devices
    return /android|iphone|ipad|ipod|windows phone/i.test(userAgent);
  }

  constructor() {
    // @ts-expect-error args
    super(...arguments);
    this.loadState();
    if (this.tiles.length === 0) {
      this.setupNewGame();
    }
    try {
      window.Telegram.WebApp.disableVerticalSwipes();
    } catch (e) {
      // EOL
    }
    if (!this.isMobile) {
      this.isInfoDialogOpen = true;
    }
  }

  setupNewGame() {
    this.tiles = [];
    this.sumScore = 0;
    this.classicScore = 0;
    this.gameOver = false;
    this.tileId = 0;
    this.addRandomTile();
    this.addRandomTile();
    this.prepareTiles();    
    this.saveState();
  }

  addRandomTile(direction?: Direction, targetIndex?: number) {
    if ( typeof targetIndex === 'number' ) {
      // console.log('Adding tile with direction:', direction, 'and targetIndex:', targetIndex+1);
    } else {
      // console.log('Adding RANDOM tile');
    }
    const emptyCells = [];
    for (let x = 0; x < this.gridSize; x++) {
      for (let y = 0; y < this.gridSize; y++) {
        if (!this.getTileAt(x, y)) {
          let cellValid = true;
          if (direction && typeof targetIndex === 'number') {
            if (direction === 'left' || direction === 'right') {
              // Horizontal movement, so we are adding in a specific row
              cellValid = x === targetIndex;
            } else if (direction === 'up' || direction === 'down') {
              // Vertical movement, so we are adding in a specific column
              cellValid = y === targetIndex;
            }
          }
          if (cellValid) {
            emptyCells.push({ x, y });
            //console.log('Cell pushed x:', x+1, 'and y:', y+1);
          }
        }
      }
    }

    if (emptyCells.length === 0) {
      return;
    }

    const randomCell = emptyCells[Math.floor(Math.random() * emptyCells.length)];
    const tile: Tile = {
      value: this.isFixedFourMode ? 4 : (Math.random() < 0.9 ? 2 : 4),
      id: this.tileId++,
      merged: false,
      className: '',
      previousPosition: null,
      x: randomCell.x,
      y: randomCell.y,
      isNew: true,
    };

    this.addReactiveProperties(tile);
    this.updateTileClass(tile);
    this.tiles.push(tile);
    this.tiles = [...this.tiles];

    if ( typeof targetIndex === 'number' ) {
      if (direction === 'up' || direction === 'down') {
        // console.log('Added to COLUMN: x:', randomCell.x+1, ' y:', randomCell.y+1);
      }
      else if (direction === 'left' || direction === 'right') {
        // console.log('Added to ROW: x:', randomCell.x+1, ' y:', randomCell.y+1);
      }
    }
  }

  addReactiveProperties(tile: Tile) {
    cellFor(tile, 'value');
    cellFor(tile, 'merged');
    cellFor(tile, 'className');
    cellFor(tile, 'previousPosition');
    cellFor(tile, 'x');
    cellFor(tile, 'y');
    cellFor(tile, 'isNew');
  }

  updateTileClass(tile: Tile) {
    const valueClassMap = {
      2: 'bg-yellow-100 text-yellow-900',
      4: 'bg-yellow-200 text-yellow-900',
      8: 'bg-yellow-300 text-yellow-900',
      16: 'bg-yellow-400 text-yellow-900',
      32: 'bg-orange-500 text-white',
      64: 'bg-orange-600 text-white',
      128: 'bg-orange-700 text-white',
      256: 'bg-red-500 text-white',
      512: 'bg-red-600 text-white',
      1024: 'bg-red-700 text-white',
      2048: 'bg-green-500 text-white',
      4096: 'bg-green-600 text-white',
      8192: 'bg-green-700 text-white',
    };
    const baseClass =
      'tile absolute flex items-center justify-center font-bold text-2xl';
    tile.className = `${baseClass} ${
      valueClassMap[tile.value as keyof typeof valueClassMap] || 'bg-gray-500 text-white'
    }`;
  }

  toggleMode = () => {
    this.isRowColMode = !this.isRowColMode;
  };

  toggleFixedFourMode = () => {
    this.isFixedFourMode = !this.isFixedFourMode;
  };

  toggleInfoDialog = () => {
    this.isInfoDialogOpen = !this.isInfoDialogOpen;
  };

  toggleSumScoreMode = () => {
    this.isSumScoreMode = !this.isSumScoreMode;
  };
 
  handleKeyDown = (event: KeyboardEvent) => {
    if (this.gameOver) {
      return;
    }
    
    let moved = false;
    let direction: Direction | null = null;
    let targetIndex: number | null = null;

    // Check if an arrow key was pressed
    if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(event.key)) {

      //console.log('Key Pressed:', event.key);
      //console.log('Shift:', event.shiftKey);
      //console.log('Ctrl:', event.ctrlKey);
      //console.log('Alt:', event.altKey);
      //console.log('Meta:', event.metaKey);

      // Determine the direction
      switch (event.key) {
        case 'ArrowUp':
          direction = 'up';
          break;
        case 'ArrowDown':
          direction = 'down';
          break;
        case 'ArrowLeft':
          direction = 'left';
          break;
        case 'ArrowRight':
          direction = 'right';
          break;
      }

      // Detect modifier keys and set targetIndex
      if (event.shiftKey) {
        targetIndex = 0; // First row/column
      } else if (event.ctrlKey) {
        targetIndex = 1; // Second row/column
      } else if (event.altKey) {
        targetIndex = 2; // Third row/column
      } else if (event.metaKey) {
        targetIndex = 3; // Fourth row/column
      }

      //Add a cell
      this.addRandomTile(direction, targetIndex);

      // Perform the move
      moved = this.move(direction);

      //Can we still move in any direction after adding the cell and moving      
      if (!this.canMove()) {
        this.gameOver = true;
      }

      this.saveState();
    }
  };


  move(direction: Direction): boolean {
    let moved = false;
    const vectors = this.getVector(direction);
    const traversals = this.buildTraversals(vectors);

    this.prepareTiles();

    traversals.x.forEach((x) => {
      traversals.y.forEach((y) => {
        const tile = this.getTileAt(x, y);
        if (tile) {
          const positions = this.findFarthestPosition({ x, y }, vectors);
          const nextTile = this.getTileAt(positions.next.x, positions.next.y);

          if (nextTile && nextTile.value === tile.value && !nextTile.merged) {
            // Merge tiles
            this.mergeTiles(tile, nextTile);
            moved = true;
          } else {
            if (
              positions.farthest.x !== tile.x ||
              positions.farthest.y !== tile.y
            ) {
              this.moveTile(tile, positions.farthest);
              moved = true;
            }
          }
        }
      });
    });

    this.tiles = this.tiles.filter((tile) => tile.value !== 0);

    return moved;
  }

  prepareTiles() {
    this.tiles.forEach((tile) => {
      tile.merged = false;
      tile.previousPosition = { x: tile.x, y: tile.y };
      tile.isNew = false;
    });
  }

  mergeTiles(source: Tile, target: Tile) {
    target.value *= 2;
    target.merged = true;
    this.updateTileClass(target);

    this.classicScore += target.value;
    
    this.sumScore = -0.5 * target.value;
    this.tiles.forEach((tile) => {
      this.sumScore += tile.value;
    });    
  
    if (this.sumScore > this.maxSumScore) {
      this.maxSumScore = this.sumScore;
    }
    if (this.classicScore > this.maxClassicScore) {
      this.maxClassicScore = this.classicScore;
    }
    

    try {
      window.Telegram.WebApp.HapticFeedback.impactOccurred('light');
    } catch (e) {
      // FINE
    }
    source.value = 0; // Mark source tile for removal
  }

  moveTile(tile: Tile, position: { x: number; y: number }) {
    tile.previousPosition = { x: tile.x, y: tile.y };
    tile.x = position.x;
    tile.y = position.y;
  }

  buildTraversals(vector: { x: number; y: number }) {
    const traversals: { x: number[], y: number[] } = { x: [], y: [] };

    for (let pos = 0; pos < this.gridSize; pos++) {
      traversals.x.push(pos);
      traversals.y.push(pos);
    }

    if (vector.x === 1) {
      traversals.x = traversals.x.reverse();
    }
    if (vector.y === 1) {
      traversals.y = traversals.y.reverse();
    }

    return traversals;
  }

  findFarthestPosition(
    position: { x: number; y: number },
    vector: { x: number; y: number },
  ) {
    let previous;
    let next = position;

    do {
      previous = next;
      next = { x: previous.x + vector.x, y: previous.y + vector.y };
    } while (this.withinBounds(next) && !this.getTileAt(next.x, next.y));

    return {
      farthest: previous,
      next: next,
    };
  }

  getVector(direction: Direction) {
    const map = {
      up: { x: -1, y: 0 },
      down: { x: 1, y: 0 },
      left: { x: 0, y: -1 },
      right: { x: 0, y: 1 },
    };
    return map[direction];
  }

  withinBounds(position: { x: number; y: number }) {
    return (
      position.x >= 0 &&
      position.x < this.gridSize &&
      position.y >= 0 &&
      position.y < this.gridSize
    );
  }

  getTileAt(x: number, y: number) {
    return this.tiles.find(
      (tile) => tile.x === x && tile.y === y && tile.value !== 0,
    );
  }

  canMove() {
    for (let x = 0; x < this.gridSize; x++) {
      for (let y = 0; y < this.gridSize; y++) {
        const tile = this.getTileAt(x, y);
        if (!tile) {
          return true;
        }
        const directions: Direction[] = ['up', 'down', 'left', 'right'];
        for (let dir of directions) {
          const vector = this.getVector(dir);
          const nextPos = { x: x + vector.x, y: y + vector.y };
          if (this.withinBounds(nextPos)) {
            const nextTile = this.getTileAt(nextPos.x, nextPos.y);
            if (!nextTile || nextTile.value === tile.value) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  resetGame = () => {
    if (window.confirm('Are you sure you want to start a new game? Your current progress will be lost.')) {
      this.setupNewGame();
      try {
        window.Telegram.WebApp.HapticFeedback.notificationOccurred('success');
      } catch (e) {
        // FINE
      }
    }
  };

  gridDisplaySize = Math.min(400, window.innerWidth);

  get tileSize() {
    return (this.gridDisplaySize / this.gridSize) * 0.8;
  }

  get gridWidth() {
    return `${this.gridDisplaySize}px`;
  }
  get gridHeigh() {
    return `${this.gridDisplaySize}px`;
  }
  get gridPlaceholder() {
    return new Array(this.gridSize).fill(null).map((_e, i) => {
      return {
        value: i,
      };
    });
  }

  get tileSizeInPX() {
    return `${this.tileSize}px`;
  }
  touchStartX = 0;
  touchStartY = 0;


  handleTouchStart = (event: TouchEvent) => {
    if (event.touches.length !== 1) {
      return;
    }
    const touch = event.touches[0];
    this.touchStartX = touch.clientX;
    this.touchStartY = touch.clientY;

    // Get the bounding rectangle of the game container
    const rect = (event.currentTarget as HTMLElement).getBoundingClientRect();

    // Calculate position relative to the game grid
    const x = this.touchStartX - rect.left;
    const y = this.touchStartY - rect.top;

    // Calculate cell dimensions
    const cellWidth = this.gridDisplaySize / this.gridSize;
    const cellHeight = this.gridDisplaySize / this.gridSize;

    // Determine row and column indices
    this.touchStartRowIndex = Math.floor(y / cellHeight);
    this.touchStartColIndex = Math.floor(x / cellWidth);

    // Clamp indices to ensure they are within bounds
    this.touchStartRowIndex = Math.max(0, Math.min(this.gridSize - 1, this.touchStartRowIndex));
    this.touchStartColIndex = Math.max(0, Math.min(this.gridSize - 1, this.touchStartColIndex));
  };


  handleTouchEnd = (event: TouchEvent) => {
    if (this.gameOver) {
      return;
    }
    const touchEndX = event.changedTouches[0].clientX;
    const touchEndY = event.changedTouches[0].clientY;

    const dx = touchEndX - this.touchStartX;
    const dy = touchEndY - this.touchStartY;

    const absDx = Math.abs(dx);
    const absDy = Math.abs(dy);

    let moved = false;
    let direction: Direction | null = null;
    let targetIndex: number | null = null;

    if (Math.max(absDx, absDy) > 10) {

      // Get the bounding rectangle of the game container
      const rect = (event.currentTarget as HTMLElement).getBoundingClientRect();

      // Calculate the starting position relative to the game grid
      const startX = this.touchStartX - rect.left;
      const startY = this.touchStartY - rect.top;

      // Calculate cell dimensions
      const cellWidth = this.gridDisplaySize / this.gridSize;
      const cellHeight = this.gridDisplaySize / this.gridSize;

      // Determine row and column indices
      const startRowIndex = Math.floor(startY / cellHeight);
      const startColIndex = Math.floor(startX / cellWidth);

      // Clamp indices to ensure they are within bounds
      const clampedRowIndex = Math.max(0, Math.min(this.gridSize - 1, startRowIndex));
      const clampedColIndex = Math.max(0, Math.min(this.gridSize - 1, startColIndex));

      if (absDx > absDy) {
        // Horizontal swipe
        if (dx > 0) {
          direction = 'right';
        } else {
          direction = 'left';
        }
        targetIndex = clampedRowIndex; // Use the row index where the swipe started
      } else {
        // Vertical swipe
        if (dy > 0) {
          direction = 'down';
        } else {
          direction = 'up';
        }
        targetIndex = clampedColIndex; // Use the column index where the swipe started
      }

      //if toggle is off, add tile to random row/col
      if (!this.isRowColMode) {
        targetIndex = null;
      }

      //Add a cell
      this.addRandomTile(direction, targetIndex);

      // Perform the move
      moved = this.move(direction);

      //Can we still move in any direction after adding the cell and moving      
      if (!this.canMove()) {
        this.gameOver = true;
        try {
          window.Telegram.WebApp.HapticFeedback.notificationOccurred('error');
        } catch (e) {
          // FINE
        }
      }
      
    }

    this.saveState();
  };

  stateToSave: null | {
    tiles: { value: number; x: number; y: number; id: number }[];
    sumScore: number;
    classicScore: number;    
    maxSumScore: number;
    maxClassicScore: number;
    gameOver: boolean;
    tileId: number;
  } = null;

  saveState() {
    const gameState = {
      tiles: this.tiles.map((tile) => ({
        value: tile.value,
        x: tile.x,
        y: tile.y,
        id: tile.id,
      })),
      sumScore: this.sumScore,
      classicScore: this.classicScore,
      maxSumScore: this.maxSumScore,
      maxClassicScore: this.maxClassicScore,
      gameOver: this.gameOver,
      tileId: this.tileId,
    };
    this.stateToSave = gameState;
    this.hideMerged();
    clearTimeout(this.saveTimeout);
    this.saveTimeout = setTimeout(()=> this.lazySave(), 3000); // 3s per save
  }

  saveTimeout = -1;
  lazySave() {
    clearTimeout(this.saveTimeout);
    const gameState = this.stateToSave;
    localStorage.setItem('gameState', JSON.stringify(gameState));
    try {
      if (this.classicScore === 0) {
        return;
      }
      window.Telegram.WebApp.CloudStorage.setItem(
        'game-2048-state',
        JSON.stringify(gameState),
      );
    } catch (e) {
      // FINE
    }
  }

  get score() {
    if( this.isSumScoreMode ) {
      return this.sumScore;
    } else {
      return this.classicScore;
    }
  }

  get maxScore() {
    if( this.isSumScoreMode ) {
      return this.maxSumScore;
    } else {
      return this.maxClassicScore;
    }
  }

  get showMaxScore() {
    if( this.isSumScoreMode ) {
      return this.maxSumScore > this.sumScore;
    } else {
      return this.maxClassicScore > this.classicScore;
    }
  }

  mergedTimeout: number | undefined = -1;
  hideMerged() {
    clearTimeout(this.mergedTimeout);
    this.mergedTimeout = setTimeout(() => {
      requestAnimationFrame(() => {
        this.tiles.forEach((t) => (t.merged = false));
      });
    }, 200);
  }

  applyState(gameState: GameState) {
    this.tiles = gameState.tiles.map((tileData) => {
      const tile: Tile = {
        value: tileData.value,
        id: tileData.id,
        merged: false,
        className: '',
        previousPosition: null,
        x: tileData.x,
        y: tileData.y,
        isNew: false,
      };
      this.addReactiveProperties(tile);
      this.updateTileClass(tile);
      return tile;
    });
    this.sumScore = gameState.sumScore;
    this.classicScore = gameState.classicScore;
    this.maxSumScore = gameState.maxSumScore || gameState.sumScore;
    this.maxClassicScore = gameState.maxClassicScore || gameState.classicScore;
    this.gameOver = gameState.gameOver;
    this.tileId = gameState.tileId;
  }
  loadState() {
    const savedState = localStorage.getItem('gameState');
    if (savedState) {
      try {
        const gameState = JSON.parse(savedState);
        this.applyState(gameState);
      } catch (e) {
        this.setupNewGame();
      }
    }

    try {
      window.Telegram.WebApp.CloudStorage.getItem(
        'game-2048-state',
        (err, raw) => {
          if (!err && raw) {
            const value = JSON.parse(raw);
            this.applyState(value);
          }
        },
      );
    } catch (e) {
      // FINE
    }
  }

  focus = (e: HTMLDivElement) => {
    requestAnimationFrame(() => {
      e.focus();
    });
    const focusTrap = () => {
      e.focus();
    };
    document.body.addEventListener('click', focusTrap);
    return () => {
      document.body.removeEventListener('click', focusTrap);
    };
  };

  <template>
    <div class='flex flex-col items-center justify-start min-h-screen'>
      <!-- Header Container -->
      <div class="relative w-full flex items-center">
        <h1 class="text-4xl font-bold mb-4 mt-4 w-full text-center">dr2048</h1>        
        <button type="button" class="absolute right-4 top p-2 border rounded" style="background-color: #888; color: black;" title="Info" {{on "click" this.toggleInfoDialog}}>❔</button>
      </div>
      <!-- Score Display -->
      <div class='text-2xl mb-4'>Score:
        {{this.score}}{{#if this.showMaxScore}}, Max:
          {{this.maxScore}}{{/if}}</div>
      <!-- Game Container -->
      <div
        class='game-container relative'
        style.width={{this.gridWidth}}
        style.height={{this.gridHeigh}}
        {{on 'keydown' this.handleKeyDown}}
        {{on 'touchstart' this.handleTouchStart}}
        {{on 'touchend' this.handleTouchEnd}}
        {{this.focus}}
        tabindex='0'
      >
        <!-- Grid Background -->
        {{#each this.gridPlaceholder as |row|}}
          {{#each this.gridPlaceholder as |col|}}
            <div
              class='tile-empty'
              style.width={{this.tileSizeInPX}}
              style.height={{this.tileSizeInPX}}
              style.top={{this.position row.value}}
              style.left={{this.position col.value}}
            ></div>
          {{/each}}
        {{/each}}

        <!-- Tiles -->
        {{#each this.tiles as |tile|}}
          <div
            class={{tile.className}}
            style.width={{this.tileSizeInPX}}
            style.height={{this.tileSizeInPX}}
            style.top={{this.position tile.x}}
            style.left={{this.position tile.y}}
            style.transform={{this.tileTransform tile}}
          >
            {{tile.value}}
          </div>
        {{/each}}
      </div>
      <!-- Toggles -->
      {{#if this.gameOver}}
        <div class='mt-4 text-red-600 text-xl font-bold' style='margin:-5px;'>Game Over!</div>
      {{/if}}
      <button
        type='button'
        class='mt-4 px-4 py-2 bg-blue-500 text-white rounded'
        {{on 'click' this.resetGame}}
      >New Game</button>
      {{#if this.isMobile}}
        <div class='flex flex-row items-center gap-[10px]'>
          <button
            type="button"
            class={{if this.isSumScoreMode "mt-4 px-4 py-2 bg-red-500 text-white rounded" "mt-4 px-4 py-2 bg-gray-500 text-white rounded"}}
            {{on 'click' this.toggleSumScoreMode}}
          >{{if this.isSumScoreMode '∑(tiles)' '∑(merged)'}}
          </button>
          <button
            type="button"
            class={{if this.isRowColMode "mt-4 px-4 py-2 bg-red-500 text-white rounded" "mt-4 px-4 py-2 bg-gray-500 text-white rounded"}}
            {{on 'click' this.toggleMode}}
          >{{if this.isRowColMode 'RowCol' 'Random'}}
          </button>
          <button
            type="button"
            class={{if this.isFixedFourMode "mt-4 px-4 py-2 bg-red-500 text-white rounded" "mt-4 px-4 py-2 bg-gray-500 text-white rounded"}}
            {{on 'click' this.toggleFixedFourMode}}
          >{{if this.isFixedFourMode 'New tile: 4' 'New tile: 2|4'}}
          </button>
          </div>
      {{/if}}      
      {{#if this.isInfoDialogOpen}}
        <div class="fixed inset-0 bg-gray-800 bg-opacity-50 flex items-center justify-center z-50" style="transform: translateY(-0%);">
          <div class="bg-gray-200 p-6 rounded shadow-lg max-w-md w-full text-center">
            <h2 class="text-2xl text-black font-bold mb-4">3x3 Mobile Only</h2>
            <p class="text-gray-900 mb-4">
              (Credits: forked from <a href="https://github.com/lifeart">@LifeArt</a>)<br><br>
              A variant of the original 2048 game with the option to remove the (mis)fortune factors.<br><br>
              <u>Mobile only</u>: swipe over a row or column to determine the destination of the new tile.<br><br>
              <i>Toggle between:</i><br>
              <b>Random mode</b> (original game play), and<br><b>RowCol mode</b> (swipe over destination row/col)<br><br>
              <b>∑(tiles)</b> (score is sum of all tiles), and<br><b>∑(merged)</b> (score is sum of merged tiles)<br>
            </p>
            <p class="text-gray-500 text-sm">
              <a href="https://bsky.app/profile/doradiology.com">bsky: @doRadiology.com</a><br><br>
            </p>
            <button type="button" class="mt-4 px-4 py-2 bg-blue-500 text-white rounded" {{on "click" this.toggleInfoDialog}}>Close</button>
          </div>
        </div>
      {{/if}}
    </div>
  </template>

  position(index: number) {
    let offset =
      (this.gridDisplaySize - this.gridSize * this.tileSize) /
      (this.gridSize - 1);
    return `${index * this.tileSize + (offset / 2) * (index + 1.5)-9}px`;
  }

  tileTransform(tile: Tile) {
    let transform = '';
    if (tile.isNew) {
      transform = 'scale(0)';
    } else if (tile.merged) {
      transform = 'scale(1.2)';
    } else {
      transform = 'scale(1)';
    }
    return transform;
  }
}
